require_relative '../spec_helper'
require 'bigdecimal'
require 'bigdecimal/util'
require 'benchmark'
require 'ruby-prof'
a = [
    [2.025, "gal"],
    [5.575, "gal"],
    [8.975, "gal"],
    [1.5, "gal"],
    [9, "gal"],
    [1.85, "gal"],
    [2.25, "gal"],
    [1.05, "gal"],
    [4.725, "gal"],
    [3.55, "gal"],
    [4.725, "gal"],
    [3.75, "gal"],
    [6.275, "gal"],
    [0.525, "gal"],
    [3.475, "gal"],
    [0.85, "gal"]
]

b = a.map{|ns,nu| Unit.new(ns.to_d, nu)}

result = RubyProf.profile(merge_fibers: true) do
  puts b.reduce(:+)
end

# print a graph profile to text
printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, {})

result = RubyProf.profile(merge_fibers: true) do
  puts b.reduce(:-)
end

# print a graph profile to text
printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, {})
