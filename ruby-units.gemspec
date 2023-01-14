lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby_units/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruby-units'
  spec.version       = RubyUnits::Unit::VERSION
  spec.authors       = ['Kevin Olbrich']
  spec.email         = ['kevin.olbrich@gmail.com']

  spec.required_rubygems_version = '>= 2.0'
  spec.required_ruby_version = '>= 2.7'
  spec.summary       = 'Provides classes and methods to perform unit math and conversions'
  spec.description   = 'Provides classes and methods to perform unit math and conversions'
  spec.homepage      = 'https://github.com/olbrich/ruby-units'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/olbrich/ruby-units'
  spec.metadata['changelog_uri'] = 'https://github.com/olbrich/ruby-units/releases'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { _1.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-html'
  spec.add_development_dependency 'solargraph'
  spec.add_development_dependency 'terminal-notifier'
  spec.add_development_dependency 'terminal-notifier-guard'
  spec.add_development_dependency 'webrick'
  spec.add_development_dependency 'yard'
end
