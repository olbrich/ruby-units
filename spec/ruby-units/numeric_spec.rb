require File.dirname(__FILE__) + '/../spec_helper'

describe Numeric do
  specify { Float.instance_methods.should include(:to_unit) }
  specify { Integer.instance_methods.should include(:to_unit) }
  specify { Fixnum.instance_methods.should include(:to_unit) }
  specify { Complex.instance_methods.should include(:to_unit) }
  specify { Bignum.instance_methods.should include(:to_unit) }
  specify { Rational.instance_methods.should include(:to_unit) }
end