require File.dirname(__FILE__) + '/../spec_helper'

describe Date do
  subject { Date.new(2011,4,1) }
  
  it {should be_instance_of Date}
  it {should respond_to :to_unit}
  it {should respond_to :to_time}
  it {should respond_to :to_date}
  
  specify { subject.to_unit.should be_instance_of Unit }
  specify { subject.to_unit.units.should == "d" }
  specify { subject.to_unit.kind.should == :time }
  
  
end