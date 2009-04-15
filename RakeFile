require 'rubygems'
require 'hoe'
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

Hoe.new('ruby-units', Unit::VERSION) do |p|
  p.rubyforge_name = 'ruby-units'
  p.summary = %q{A model that performs unit conversions and unit math}
  p.email = 'kevin.olbrich+ruby_units@gmail.com'
  p.url = 'http://rubyforge.org/projects/ruby-units'
  p.description = "This library handles unit conversions and unit math"
  p.changes = p.paragraphs_of('CHANGELOG.txt', 0..1).join("\n\n")
  p.author = 'Kevin Olbrich, Ph.D'
end

# vim: syntax=Ruby
