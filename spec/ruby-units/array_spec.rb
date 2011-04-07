require File.dirname(__FILE__) + '/../spec_helper'

describe Array do
  
  subject { [1, 'cm'] }
  
  it {should be_kind_of Array}
  it {should respond_to :to_unit}
  
  specify { subject.to_unit.should be_instance_of Unit}
  specify { subject.to_unit.should == "1 cm".to_unit }
  specify { subject.to_unit('mm').should == "10 mm".to_unit}
  
end