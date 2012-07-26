# -*- encoding: utf-8 -*-
require File.expand_path('../lib/freeplay/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Peter Jones"]
  gem.email         = ["pjones@pmade.com"]
  gem.description   = `head -1 README.md|sed 's/^# *//'`
  gem.summary       = "The Freeplay client is used to connect a player to the server."
  gem.homepage      = "git://pmade.com/freeplay"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "freeplay"
  gem.require_paths = ["lib"]
  gem.version       = Freeplay::VERSION

  gem.add_dependency('eventmachine', '~> 0.12.10')
  gem.add_dependency('gtk2',         '~> 1.1.4')
end
