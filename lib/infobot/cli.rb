require 'thor'

module InfoBot
  # Main interface to InfoBot
  class CLI < Thor
    class_option :config, banner: 'PATH',
                          default: 'config.yml',
                          desc: 'Configuration file',
                          type: :string

    desc 'console', 'Open a console in the context of InfoBot'
    def console
      require 'pry'

      bot.pry
    end

    desc 'generate', 'Generate local files and update wiki content'
    def generate
      bot.generate_local_files
      bot.generate_meeting_page
      bot.generate_wiki_pages
    end

    private

    # InfoBot instance
    def bot
      @_bot ||= begin
        require 'infobot'

        InfoBot::Bot.new(options[:config])
      end
    end
  end
end
