#!/usr/bin/env ruby

require_relative 'infobot'

# Initialize
options = {
  calendar_feed: 'https://www.google.com/calendar/ical/dksq9gdtuasak0v97g59tnpo60%40group.calendar.google.com/public/basic.ics',
  file_builds_path: './file_builds',
  file_templates_path: './file_templates',
  mediawiki_endpoint: 'http://gslug.org/api.php',
  mediawiki_password: ENV['MW_PASSWORD'],
  mediawiki_username: ENV['MW_USERNAME'],
  meeting_template_path: './meeting_template.wiki.erb',
  meeting_regex: /GSLUG/,
  wiki_pages_path: './wiki_pages'
}
infobot = InfoBot.new(options)

# Sync
infobot.build_static_files!
infobot.generate_next_meeting_page!
infobot.update_wiki_templates!
