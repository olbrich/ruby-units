require 'rubygems'
require 'rake'
require 'rake/testtask'
require './lib/ruby-units'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ruby-units"
    gem.summary = %Q{A class that performs unit conversions and unit math}
    gem.description = %Q{Provides classes and methods to perform unit math and conversions}
    gem.authors = ["Kevin Olbrich, Ph.D."]
    gem.email = ["kevin.olbrich+ruby_units@gmail.com"]
    gem.homepage = "https://github.com/olbrich/ruby-units"
    gem.files.exclude(".*","test/**/*","spec/**/*","autotest/**/*", "Gemfile")
    gem.license = "MIT"
	gem.post_install_message = <<-EOS
====================
Deprecation Warning
====================

Several convenience methods that ruby-units added to the string class have
been deprecated in this release.  These methods include String#to, String#from, String#ago, String#before and others.
If your code relies on these functions, they can be added back by adding this line to your code.

require 'ruby-units/string/extras'
# note that these methods do not play well with Rails, which is one of the reasons they are being removed.

The extra functions mostly work the same, but will no longer properly handle cases when they are called with strings..

'min'.from("4-1-2011") # => Exception

Pass in a Date, Time, or DateTime object to get the expected result.

They will go away completely in the next release, so it would be a good idea to refactor your code
to avoid using them.  They will also throw deprecation warnings when they are used.
EOS
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

begin
  require 'simplecov'
  desc "code coverage report using simplecov (ruby 1.9+)"
  task :simplecov do
    ENV['COVERAGE']='true'
    Rake::Task['spec'].invoke
  end
rescue LoadError
end

begin
  require 'rspec/core/rake_task'

  desc "Run specs"
  RSpec::Core::RakeTask.new do |spec|
	puts
	# puts %x{rvm current}
	puts
  end
  
  desc  "Run all specs with rcov"
  RSpec::Core::RakeTask.new("spec:rcov") do |t|
    t.rcov = true
    t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/,features\/}
  end
rescue LoadError
end

task :specs => :spec

rubies = {
      "ruby-1.8.7" => %w{ruby-1.8.7-p357@ruby-units ruby-1.8.7-p357@ruby-units-with-chronic},
      "ruby-1.9.2" => %w{ruby-1.9.2-p290@ruby-units ruby-1.9.2-p290@ruby-units-with-chronic},
      "rbx"        => %w{rbx-head@ruby-units},
      "jruby"      => %w{jruby-1.6.7@ruby-units}
    }

rubies.each do |name, ruby|
  desc "Run Spec against #{name}"
  task "spec:#{name}" do
    sh "rvm #{ruby.join(',')} do rake spec"
  end
end

desc "Run specs against several ruby versions, requires rvm"
task "spec:all" => rubies.keys.map {|name| "spec:#{name}"}

task :default => :spec
