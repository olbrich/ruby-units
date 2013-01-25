require File.dirname(__FILE__) + '/../spec_helper'

describe Object do
  specify { Unit('1 mm').should be_instance_of Unit}
  specify { U('1 mm').should be_instance_of Unit}
  specify { u('1 mm').should be_instance_of Unit}
  specify { (Unit(0) + Unit(0)).should be_instance_of Unit}
  specify { (Unit(0) - Unit(0)).should be_instance_of Unit}
end