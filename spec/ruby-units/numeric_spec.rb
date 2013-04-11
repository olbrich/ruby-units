require File.dirname(__FILE__) + '/../spec_helper'

# some rubies return an array of strings for .instance_methods and others return an array of symbols
# so let's stringify them before we compare
describe Numeric do
  specify { Float.instance_methods.map {|m| m.to_s}.should include("to_unit") }
  specify { Integer.instance_methods.map {|m| m.to_s}.should include("to_unit") }
  specify { Fixnum.instance_methods.map {|m| m.to_s}.should include("to_unit") }
  specify { Complex.instance_methods.map {|m| m.to_s}.should include("to_unit") } if defined?(Complex)
  specify { Bignum.instance_methods.map {|m| m.to_s}.should include("to_unit") }
  specify { Rational.instance_methods.map {|m| m.to_s}.should include("to_unit") }
end
