require File.dirname(__FILE__) + '/../spec_helper'

describe "Create some simple units" do
  describe Unit("1") do
    it {should be_a Numeric}
    it {should be_an_instance_of Unit}
    its(:scalar) {should == 1}
    its(:units) {should be_empty}
    its(:kind) {should == :unitless}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should be_base}
    it {should be_unitless}
    its(:base) {should == Unit("1")}  
  end

  describe Unit("1 mm") do
    it {should be_a Numeric}
    it {should be_an_instance_of Unit}
    its(:scalar) {should == 1}
    its(:units) {should == "mm"}
    its(:kind) {should == :length}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should_not be_base}
    it {should_not be_unitless}
    its(:base) {should == Unit("0.001 m")}
  end

  describe Unit("10 m/s^2") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should == 10}
    its(:units) {should == "m/s^2"}
    its(:kind) {should == :acceleration}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should be_base}
    it {should_not be_unitless}
    its(:base) {should == Unit("10 m/s^2")}  
  end

  describe Unit("5ft 6in") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should == 5.5}
    its(:units) {should == "ft"}
    its(:kind) {should == :length}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should_not be_base}
    it {should_not be_unitless}
    its(:base) {should be_within(Unit("0.01 m")).of Unit("1.6764 m")}
    specify { subject.to_s(:ft).should == %{5'6"} }
  end

  describe Unit("6lbs 5oz") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_within(0.001).of 6.312}
    its(:units) {should == "lbs"}
    its(:kind) {should == :mass}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should_not be_base}
    it {should_not be_unitless}
    its(:base) {should be_within(Unit("0.01 kg")).of Unit("2.8633 kg")}
    specify { subject.to_s(:lbs).should == "6 lbs, 5 oz" }
  end

  describe Unit("100 tempC") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_within(0.001).of 100}
    its(:units) {should == "tempC"}
    its(:kind) {should == :temperature}
    it {should be_temperature}
    it {should be_degree}
    it {should_not be_base}
    it {should_not be_unitless}
    its(:base) {should be_within(Unit("0.01 degK")).of Unit("373.15 tempK")}
    its(:temperature_scale) {should == "degC"}
  end

  describe Unit(Time.now) do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_a(Numeric)}
    its(:units) {should == "s"}
    its(:kind) {should == :time}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should be_base}
    it {should_not be_unitless}
    its(:base) {should be_a(Numeric)}
    its(:temperature_scale) {should be_nil}
  end

  # describe Unit("100 degC") do
  #   it {should be_an_instance_of Unit}
  #   its(:scalar) {should be_within(0.001).of 100}
  #   its(:units) {should == "degC"}
  #   its(:kind) {should == :temperature}
  #   it {should_not be_temperature}
  #   it {should be_degree}
  #   it {should_not be_base}
  #   it {should_not be_unitless}
  #   its(:base) {should be_within(Unit("0.01 degK")).of Unit("373.15 tempK")}
  # end
  
  describe Unit("75%") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_a(Numeric)}
    its(:units) {should == "%"}
    its(:kind) {should == :unitless}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should_not be_base}
    it {should_not be_unitless}
    its(:base) {should be_a(Numeric)}
    its(:temperature_scale) {should be_nil}    
  end

  describe Unit("180 deg") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_a(Numeric)}
    its(:units) {should == "deg"}
    its(:kind) {should == :angle}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should_not be_base}
    it {should_not be_unitless}
    its(:base) {should be_a(Numeric)}
    its(:temperature_scale) {should be_nil}    
  end
  
  describe Unit("1 radian") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_a(Numeric)}
    its(:units) {should == "rad"}
    its(:kind) {should == :angle}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should be_base}
    it {should_not be_unitless}
    its(:base) {should be_a(Numeric)}
    its(:temperature_scale) {should be_nil}    
  end

  describe Unit("12 dozen") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_a(Numeric)}
    its(:units) {should == "doz"}
    its(:kind) {should == :unitless}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should_not be_base}
    it {should_not be_unitless}
    its(:base) {should be_a(Numeric)}
    its(:temperature_scale) {should be_nil}    
  end

end

describe Unit do
  it "is a subclass of Numeric" do
     described_class.should < Numeric
  end
  it "is Comparable" do 
    described_class.should < Comparable
  end
end

describe "Unit Conversions" do
  context "Unit should detect if two units are 'compatible' (i.e., can be converted into each other)" do
    specify { Unit("1 ft").should =~ Unit('1 m')}
    specify { Unit("1 ft").should =~ "m"}
    specify { Unit("1 ft").should be_compatible_with Unit('1 m')}
    specify { Unit("1 ft").should be_compatible_with "m"}
    specify { Unit("1 m").should be_compatible_with Unit('1 kg*m/kg')}
    
    specify { Unit("1 ft").should_not =~ Unit('1 kg')}
    specify { Unit("1 ft").should_not be_compatible_with Unit('1 kg')}
  end
  
  context "Unit should perform unit conversions between compatible units" do
    specify { Unit("1 s").to("ns").should == Unit("1e9 ns")}
  end
end