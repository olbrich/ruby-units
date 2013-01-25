require File.dirname(__FILE__) + '/../spec_helper'

describe "Github issue #49" do
  let(:a) { Unit("3 cm^3")}
  let(:b) { Unit.new(a)}

  it "should subtract a unit properly from one initialized with a unit" do
    (b - Unit("1.5 cm^3")).should == Unit("1.5 cm^3")
  end
end