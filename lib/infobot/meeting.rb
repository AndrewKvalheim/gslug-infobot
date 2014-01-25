require 'active_support/core_ext/object/blank'

module InfoBot
  # Simplified meeting representation
  class Meeting
    def initialize(event)
      @event = event
    end

    # End time
    def end
      @event.dtend.to_time.getlocal
    end

    # Location, if there is one
    def location
      @event.location.presence
    end

    # Title of the wiki page
    def wiki_page_title
      "Meeting #{start.strftime('%F')}"
    end

    # Start time
    def start
      @event.dtstart.to_time.getlocal
    end

    # Topic, if there is one
    def topic
      @event.description.presence
    end
  end
end
