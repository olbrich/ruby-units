require File.dirname(__FILE__) + '/../spec_helper'

# some rubies return an array of strings for .instance_methods and others return an array of symbols
# so let's stringify them before we compare
describe Numeric do
  specify { expect(Float.instance_methods.map(&:to_s)).to include('to_unit') }
  specify { expect(Integer.instance_methods.map(&:to_s)).to include('to_unit') }
  specify { expect(Integer.instance_methods.map(&:to_s)).to include('to_unit') }
  specify { expect(Complex.instance_methods.map(&:to_s)).to include('to_unit') }
  specify { expect(Integer.instance_methods.map(&:to_s)).to include('to_unit') }
  specify { expect(Rational.instance_methods.map(&:to_s)).to include('to_unit') }
end
