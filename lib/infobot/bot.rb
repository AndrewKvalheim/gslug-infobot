require 'active_support'
require 'active_support/core_ext'
require 'fileutils'
require 'media_wiki'
require 'memoizer'
require 'pathname'
require 'thor'
require 'tilt'
require 'uri'
require 'yaml'

# Utilities for automating updates to the GSLUG wiki and website
module InfoBot
  # MediaWiki bot
  class Bot
    include Memoizer

    def initialize(config_path)
      @config = YAML.load_file(config_path).deep_merge(
        mediawiki: {
          username: ENV['MW_USERNAME'],
          password: ENV['MW_PASSWORD']
        }
      )
    end

    # Generate local files from templates
    def generate_local_files
      local_files.each do |static_file|
        FileUtils.mkdir_p File.dirname(static_file.destination_path)
        IO.write static_file.destination_path, render(static_file.path)
      end
    end

    # Generate and publish a wiki page for the next meeting, if necessary
    def generate_meeting_page
      return unless calendar.next_meeting

      title = calendar.next_meeting.wiki_page_title
      content = render(@config[:templates][:meeting])

      unlock title if soft_create(title, content)
    end

    # Generate and publish wiki pages from templates
    def generate_wiki_pages
      wiki_pages.each do |wiki_page|
        edit wiki_page.title, render(wiki_page.path)
      end
    end

    private

    # Append content to an existing page
    def append(title, content)
      edit title, [get(title), content].join("\n")
    end

    # Calendar interface instance
    def calendar
      Calendar.new(@config[:calendar])
    end
    memoize :calendar

    # Create a new page on the wiki
    def create(title, body)
      mediawiki.create title, body
    end

    # Overwrite an existing page on the wiki
    def edit(title, body)
      mediawiki.edit title, body
    end

    # Get the content of a page
    def get(title)
      mediawiki.get(title)
    end

    # List of local files to generate
    def local_files
      template_dir = @config[:templates][:local_files]
      paths = Dir.glob(File.join(template_dir, '*.erb'))
      build_path = Pathname.new(@config[:build_path])

      paths.map do |path|
        Resources::LocalFile.new(path, build_path)
      end
    end
    memoize :local_files

    # MediaWiki API instance
    def mediawiki
      credentials = [@config[:mediawiki][:username],
                     @config[:mediawiki][:password]]
      fail 'Missing MediaWiki credentials.' unless credentials.all?

      endpoint = @config[:mediawiki][:endpoint]
      gateway = MediaWiki::Gateway.new(endpoint, bot: true)
      gateway.login(*credentials)

      gateway
    end
    memoize :mediawiki

    # Check whether the wiki page exists
    def page_exists?(title)
      !mediawiki.list(title).empty?
    end
    memoize :page_exists?

    # Render a template file and return the resulting content
    def render(template_path, **locals)
      Tilt.new(template_path, trim: '-').render(self, **locals)
    end
    memoize :render

    # Create a new page on the wiki, unless it already exists
    def soft_create(title, body)
      create title, body unless page_exists?(title)
    end

    # Add a title to the list of unlocked pages
    def unlock(title)
      append 'MediaWiki:Unlockedpages', "* [[#{title}]]"
    end

    # List of wiki pages to generate
    def wiki_pages
      template_dir = @config[:templates][:wiki_pages]
      paths = Dir.glob(File.join(template_dir, '*.wiki.erb'))

      paths.map do |path|
        Resources::WikiPage.new(path)
      end
    end
    memoize :wiki_pages

    # Convert the title of a wiki page into a relative URL
    def wiki_url(title)
      "/wiki/#{URI.escape(title.tr(' ', '_'))}"
    end
  end
end
