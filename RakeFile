require 'rubygems'
require 'hoe'

Hoe.plugin :yard

require './lib/ruby_units/units'
require './lib/ruby_units/ruby-units'

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.test_files = FileList['test/test*.rb']
    #t.verbose = true     # uncomment to see the executed command
  end
rescue
end

Hoe.spec('ruby-units') do |p|
  p.yard_title = "Ruby-Units"
  p.yard_markup = "markdown"
  p.version = Unit::VERSION
  p.rubyforge_name = 'ruby-units'
  p.summary = %q{A class that performs unit conversions and unit math}
  p.email = 'kevin.olbrich+ruby_units@gmail.com'
  p.url = 'http://github.com/olbrich/ruby-units'
  p.description = "This library handles unit conversions and unit math"
  p.changes = p.paragraphs_of('CHANGELOG.txt', 0..1).join("\n\n")
  p.author = 'Kevin Olbrich, Ph.D'
end