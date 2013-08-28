require 'active_support/core_ext'
require 'erb'
require 'fileutils'
require 'media_wiki'
require 'open-uri'
require 'pathname'
require 'ri_cal'
require 'tilt'
require 'uri'

class InfoBot
  ERB_OPTIONS = {trim: '-'}

  def initialize options = []
    @options ||= options
  end

  def build_static_files!
    static_files.each do |static_file|
      template = Tilt.new(static_file.path, ERB_OPTIONS)
      output = template.render(self)

      FileUtils.mkdir_p File.dirname(static_file.destination_path)
      IO.write static_file.destination_path, output
    end
  end

  def generate_next_meeting_page!
    if next_meeting? && mediawiki.list(next_meeting_page_name).empty?
      template = Tilt.new(@options[:meeting_template_path], ERB_OPTIONS)
      output = template.render(self)

      mediawiki.create next_meeting_page_name, output, bot: true
    end
  end

  def next_meeting?
    !! next_meeting
  end

  def next_meeting_end
    @_next_meeting_end ||= begin
      raise 'No next meeting found.' unless next_meeting

      next_meeting.dtend.to_time.getlocal
    end
  end

  def next_meeting_location
    @_next_meeting_location ||= begin
      raise 'No next meeting found.' unless next_meeting

      location = next_meeting.location

      location unless location.empty?
    end
  end

  def next_meeting_page_name
    @_next_meeting_page_name ||= begin
      raise 'No next meeting found.' unless next_meeting

      "Meeting #{next_meeting_start.strftime('%F')}"
    end
  end

  def next_meeting_start
    @_next_meeting_start ||= begin
      raise 'No next meeting found.' unless next_meeting

      next_meeting.dtstart.to_time.getlocal
    end
  end

  def update_wiki_templates!
    wiki_pages.each do |wiki_page|
      template = Tilt.new(wiki_page.path, ERB_OPTIONS)
      output = template.render(self)

      mediawiki.edit wiki_page.name, output, bot: true
    end
  end

  private

  def build_path
    @_build_path ||= Pathname.new(@options[:file_builds_path])
  end

  def calendar
    @_calendar ||= begin
      calendars = open(@options[:calendar_feed]) do |file|
        RiCal.parse(file)
      end

      calendars.first
    end
  end

  def mediawiki
    @_mediawiki ||= begin
      credentials = [
        @options[:mediawiki_username],
        @options[:mediawiki_password]
      ]
      raise 'Missing MediaWiki credentials.' unless credentials.all?

      gateway = MediaWiki::Gateway.new(@options[:mediawiki_endpoint])
      gateway.login *credentials

      gateway
    end
  end

  def next_meeting
    @_next_meeting ||= begin
      calendar.events.map { |event|
        if event.recurs?
          event.occurrences(overlapping: [Date.today, Date.today.next_year])
        else
          event
        end
      }.flatten.select { |event|
        event.summary =~ @options[:meeting_regex] &&
        event.dtstart > DateTime.now
      }.sort { |a, b|
        a.dtstart <=> b.dtstart
      }.first
    end
  end

  def static_files
    @_static_files ||= begin
      paths = Dir.glob(File.join(@options[:file_templates_path], '*.erb'))

      paths.map do |path|
        StaticFile.new(path, build_path)
      end
    end
  end

  def wiki_pages
    @_wiki_pages ||= begin
      paths = Dir.glob(File.join(@options[:wiki_pages_path], '*.wiki.erb'))

      paths.map do |path|
        WikiPage.new(path)
      end
    end
  end
end

class StaticFile
  def initialize path, build_path
    @build_path ||= build_path
    @pathname ||= Pathname.new(path)
  end

  def destination_path
    @_destination_path ||= begin
      @build_path + @pathname.basename('.erb')
    end
  end

  def path
    @_path ||= @pathname.to_s
  end
end

class WikiPage
  def initialize path
    @pathname ||= Pathname.new(path)
  end

  def name
    @_name ||= @pathname.basename('.wiki.erb').to_s
  end

  def path
    @_path ||= @pathname.to_s
  end
end
