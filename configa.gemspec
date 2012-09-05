# -*- encoding: utf-8 -*-
require File.expand_path('../lib/configa/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["fl00r"]
  gem.email         = ["fl00r@yandex.ru"]
  gem.description   = %q{YAML configuration file parser}
  gem.summary       = %q{Configa makes it easier to use multi environment YAML configs}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "configa"
  gem.require_paths = ["lib"]
  gem.version       = Configa::VERSION
end
