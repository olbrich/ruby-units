require_relative "spec_helper"

# some rubies return an array of strings for .instance_methods and others return an array of symbols
# so let's stringify them before we compare
describe Numeric do

  specify { expect(Float.instance_methods.map {|m| m.to_s}).to include("to_unit") }
  specify { expect(Integer.instance_methods.map {|m| m.to_s}).to include("to_unit") }
  specify { expect(Fixnum.instance_methods.map {|m| m.to_s}).to include("to_unit") }
  specify { expect(Complex.instance_methods.map {|m| m.to_s}).to include("to_unit") }
  specify { expect(Bignum.instance_methods.map {|m| m.to_s}).to include("to_unit") }
  specify { expect(Rational.instance_methods.map {|m| m.to_s}).to include("to_unit") }

  # create with another unit
  describe 10.unit(Unit.new("1 mm")) do
    its(:units) { should == "mm" }
    its(:scalar) { should == 10 }
  end

end
