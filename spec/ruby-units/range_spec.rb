require File.dirname(__FILE__) + '/../spec_helper'

describe "Range" do
  
  context "of integer units" do
    subject { (Unit('1 mm')..Unit('3 mm')) }
    it { should include(Unit('2 mm')) }
    its(:to_a) { should == [ Unit('1 mm'), Unit('2 mm'), Unit('3 mm') ] }
  end
  
  context "of floating point units" do
    subject { (Unit('1.5 mm')..Unit('3.5 mm')) }
    it { should include(Unit('2.0 mm')) }
    specify { expect { subject.to_a }.to raise_exception(ArgumentError)}
  end
end