# InfoBot

[InfoBot][] is a [MediaWiki bot][bot] for updating the [GSLUG][] wiki and
website.

## Installation

Clone the repository and run `bundle install`. Set the environment variables
`MW_USERNAME` and `MW_PASSWORD` to the bot's MediaWiki credentials.

## Usage

Run `bundle exec infobot` for a list of available commands:

    $ infobot
    Commands:
      infobot console         # Open a console in the context of InfoBot
      infobot generate        # Generate local files and update wiki content
      infobot help [COMMAND]  # Describe available commands or one specific command

    Options:
      [--config=PATH]  # Configuration file
                       # Default: config.yml


  [bot]: http://www.mediawiki.org/wiki/bot
  [gslug]: http://gslug.org/
  [infobot]: http://gslug.org/wiki/User:InfoBot
