# Generated data
git_files       = `git ls-files -z`.split("\0")
git_executables = git_files.grep(%r{^bin/}).map{ |path| File.basename(path) }

Gem::Specification.new do |gem|
  # Metadata
  gem.name                  = 'infobot'
  gem.version               = '0.0.1'
  gem.platform              = Gem::Platform::RUBY
  gem.required_ruby_version = '~> 2.0'
  gem.license               = 'GPL-3.0'
  gem.authors               = ['Andrew Kvalheim']
  gem.summary               = 'A MediaWiki bot for updating the GSLUG wiki and website'
  gem.homepage              = 'http://gslug.org/wiki/User:InfoBot'

  # Contents
  gem.files         = git_files
  gem.executables   = git_executables
  gem.require_paths = ['lib']

  # Dependencies
  gem.add_runtime_dependency 'activesupport', '~> 4.0'
  gem.add_runtime_dependency 'erubis'
  gem.add_runtime_dependency 'mediawiki-gateway', '~> 0.5.2'
  gem.add_runtime_dependency 'memoizer', '~> 1.0'
  gem.add_runtime_dependency 'pry', '~> 0.9'
  gem.add_runtime_dependency 'ri_cal', '~> 0.8'
  gem.add_runtime_dependency 'thor', '~> 0.18'
  gem.add_runtime_dependency 'tilt', '~> 2.0'

  # Development environment
  gem.add_development_dependency 'cane'
end
