require_relative '../lib/ruby-units'
require 'pry'
require 'ruby-prof'

# profile the code
result = RubyProf.profile do
  p = RubyUnits::Unit.new(100, 'kPa')
  v = RubyUnits::Unit.new(1, 'm^3')
  n = RubyUnits::Unit.new(1, 'mole')
  r = RubyUnits::Unit.new(8.31451, 'J/mol*degK')
  t = ((p * v) / (n * r)).convert_to('tempK')
  puts t
end

# print a graph profile to text
printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, min_percent: 1.0, sort_method: :self_time)
