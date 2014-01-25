require 'memoizer'
require 'open-uri'
require 'ri_cal'

module InfoBot
  # Interface to calendar events
  class Calendar
    include Memoizer

    def initialize(config)
      @config = config
    end

    # List of all events
    def events
      calendars = open(@config[:feed_url]) do |feed|
        RiCal.parse(feed)
      end

      as_occurrences(calendars.first.events).sort_by { |event| event.dtstart }
    end
    memoize :events

    # Next meeting, if one exists
    def next_meeting
      event = events.detect do |event|
        event.dtstart > DateTime.now &&
        event.summary =~ @config[:meeting_regex]
      end

      Meeting.new(event) if event
    end
    memoize :next_meeting

    private

    # Replace recurring events with a year's worth of individual occurrences
    def as_occurrences(events)
      events.flat_map do |event|
        if event.recurs?
          event.occurrences(overlapping: [Date.today, Date.today.next_year])
        else
          event
        end
      end
    end
  end
end
