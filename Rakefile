require 'rubygems'
require 'rake'
require 'rake/testtask'
require './lib/ruby-units'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'ruby-units'
    gem.summary = 'A class that performs unit conversions and unit math'
    gem.description = 'Provides classes and methods to perform unit math and conversions'
    gem.authors = ['Kevin Olbrich, Ph.D.']
    gem.email = ['kevin.olbrich+ruby_units@gmail.com']
    gem.homepage = 'https://github.com/olbrich/ruby-units'
    gem.files.exclude('.*', 'test/**/*', 'spec/**/*', 'Gemfile', 'Guardfile')
    gem.license = 'MIT'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end

require 'rspec/core/rake_task'
desc 'Run specs'
RSpec::Core::RakeTask.new

task default: :spec
