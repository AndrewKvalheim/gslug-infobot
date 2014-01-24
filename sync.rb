#!/usr/bin/env ruby

require 'yaml'
require_relative 'infobot'

# Initialize
options = YAML.load_file('config.yml').merge(
  mediawiki_password: ENV['MW_PASSWORD'],
  mediawiki_username: ENV['MW_USERNAME'],
)
infobot = InfoBot.new(options)

# Sync
infobot.build_static_files!
infobot.generate_next_meeting_page!
infobot.update_wiki_templates!
