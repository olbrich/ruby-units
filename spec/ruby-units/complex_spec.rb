require File.dirname(__FILE__) + '/../spec_helper'

describe Complex do
  subject { Complex(1,-1) }
  
  it {should be_kind_of Complex}
  it {should respond_to :to_unit}
  
  specify { subject.to_unit.should be_instance_of Unit}
  specify { subject.to_unit.should == "1-1i".to_unit }
  specify { subject.to_unit('mm').should == "1-1i mm".to_unit}
  
end