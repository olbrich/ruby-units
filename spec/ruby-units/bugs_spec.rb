require File.dirname(__FILE__) + '/../spec_helper'

describe "Github issue #49" do
  let(:a) { Unit("3 cm^3")}
  let(:b) { Unit.new(a)}

  it "should subtract a unit properly from one initialized with a unit" do
    (b - Unit("1.5 cm^3")).should == Unit("1.5 cm^3")
  end
end

describe "Github issue #48" do
  it "should not leak mathn" do
    if ENV['WITHOUT_MATHN']
      (30/20).should be_kind_of Fixnum
    end
  end
end

describe "Github issue #43" do
  it "should return a Float for Math::sqrt" do
    if ENV['WITHOUT_MATHN']
      Math.sqrt(100).should be_kind_of Float
    end
  end
end
