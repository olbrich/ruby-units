require File.dirname(__FILE__) + '/../spec_helper'

describe "Create some simple units" do
  describe Unit("1") do
    it {should be_a Numeric}
    it {should be_an_instance_of Unit}
    its(:scalar) {should === 1}
    its(:scalar) {should be_an Integer}
    its(:units) {should be_empty}
    its(:kind) {should == :unitless}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should be_base}
    it {should be_unitless}
    its(:base) {should == subject}  
  end

  describe Unit(1) do
    it {should be_a Numeric}
    it {should be_an_instance_of Unit}
    its(:scalar) {should === 1}
    its(:scalar) {should be_an Integer}
    its(:units) {should be_empty}
    its(:kind) {should == :unitless}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should be_base}
    it {should be_unitless}
    its(:base) {should == subject}  
  end
  
  describe Unit(Rational(1,2)) do
    it {should be_a Numeric}
    it {should be_an_instance_of Unit}
    its(:scalar) {should === Rational(1,2)}
    its(:scalar) {should be_a Rational}
    its(:units) {should be_empty}
    its(:kind) {should == :unitless}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should be_base}
    it {should be_unitless}
    its(:base) {should == subject}  
  end

  describe Unit(0.5) do
    it {should be_a Numeric}
    it {should be_an_instance_of Unit}
    its(:scalar) {should === 0.5}
    its(:scalar) {should be_a Float}
    its(:units) {should be_empty}
    its(:kind) {should == :unitless}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should be_base}
    it {should be_unitless}
    its(:base) {should == subject}  
  end

  describe Unit(Complex(1,1)) do
    it {should be_a Numeric}
    it {should be_an_instance_of Unit}
    its(:scalar) {should === Complex(1,1)}
    its(:scalar) {should be_a Complex}
    its(:units) {should be_empty}
    its(:kind) {should == :unitless}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should be_base}
    it {should be_unitless}
    its(:base) {should == subject}  
  end

  describe Unit("1 mm") do
    it {should be_a Numeric}
    it {should be_an_instance_of Unit}
    its(:scalar) {should == 1}
    its(:scalar) {should be_an Integer}
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
    its(:scalar) {should be_an Integer}
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
    its(:scalar) {should be_an Integer}
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
    its(:scalar) {should be_a Numeric}
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
    its(:scalar) {should be_a Numeric}
    its(:units) {should == "rad"}
    its(:kind) {should == :angle}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should be_base}
    it {should_not be_unitless}
    its(:base) {should be_a Numeric}
    its(:temperature_scale) {should be_nil}    
  end

  describe Unit("12 dozen") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_an Integer}
    its(:units) {should == "doz"}
    its(:kind) {should == :unitless}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should_not be_base}
    it {should_not be_unitless}
    its(:base) {should be_a Numeric}
    its(:temperature_scale) {should be_nil}    
  end

  describe Unit("1/2 kg") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_an Rational}
    its(:units) {should == "kg"}
    its(:kind) {should == :mass}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should be_base}
    it {should_not be_unitless}
    its(:base) {should be_a Numeric}
    its(:temperature_scale) {should be_nil}    
  end

  describe Unit("1/2 kg/m") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_an Rational}
    its(:units) {should == "kg"}
    its(:kind) {should == :mass}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should be_base}
    it {should_not be_unitless}
    its(:base) {should be_a Numeric}
    its(:temperature_scale) {should be_nil}    
  end
  

end

describe "Unit handles attempts to create bad units" do
  specify "no empty strings" do
    expect {Unit("")}.to raise_error(ArgumentError,"No Unit Specified")
  end

  specify "no blank strings" do
    expect {Unit("   ")}.to raise_error(ArgumentError,"No Unit Specified")
  end

  specify "no strings with tabs" do
    expect {Unit("\t")}.to raise_error(ArgumentError,"No Unit Specified")
  end

  specify "no strings with newlines" do
    expect {Unit("\n")}.to raise_error(ArgumentError,"No Unit Specified")
  end

  specify "no strings that don't specify a valid unit" do
    expect {Unit("random string")}.to raise_error(ArgumentError,"'random string' Unit not recognized")
  end

  specify "no undefined units" do
    expect {Unit("1 mFoo")}.to raise_error(ArgumentError,"'1 mFoo' Unit not recognized")
  end

  specify "no units with powers greater than 19" do
    expect {Unit("1 m^20")}.to raise_error(ArgumentError, "Power out of range (-20 < net power of a unit < 20)")
  end

  specify "no units with powers less than 19" do
    expect {Unit("1 m^-20")}.to raise_error(ArgumentError, "Power out of range (-20 < net power of a unit < 20)")
  end

  specify "no temperatures less than absolute zero" do
    expect {Unit("-100 tempK")}.to raise_error(ArgumentError,"Temperatures must not be less than absolute zero")
    expect {Unit("-100 tempR")}.to raise_error(ArgumentError,"Temperatures must not be less than absolute zero")
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

describe "Unit Comparisons" do
  context "Unit should detect if two units are 'compatible' (i.e., can be converted into each other)" do
    specify { Unit("1 ft").should =~ Unit('1 m')}
    specify { Unit("1 ft").should =~ "m"}
    specify { Unit("1 ft").should be_compatible_with Unit('1 m')}
    specify { Unit("1 ft").should be_compatible_with "m"}
    specify { Unit("1 m").should be_compatible_with Unit('1 kg*m/kg')}    
    specify { Unit("1 ft").should_not =~ Unit('1 kg')}
    specify { Unit("1 ft").should_not be_compatible_with Unit('1 kg')}
  end
  
  context "Equality" do
    context "units of same kind" do
      specify { Unit("1000 m").should == Unit('1 km')}
      specify { Unit("100 m").should_not == Unit('1 km')}
      specify { Unit("1 m").should == Unit('100 cm')}
    end
    
    context "units of incompatible types" do
      specify { Unit("1 m").should_not == Unit("1 kg")}
    end
    
    context "units with a zero scalar are equal" do
      specify {Unit("0 m").should == Unit("0 s")}
      specify {Unit("0 m").should == Unit("0 kg")}
      
      context "except for temperature units" do
        specify {Unit("0 tempK").should == Unit("0 m")}
        specify {Unit("0 tempR").should == Unit("0 m")}
        specify {Unit("0 tempC").should_not == Unit("0 m")}
        specify {Unit("0 tempF").should_not == Unit("0 m")}
      end
    end
  end
  
  context "Equivalence" do
    context "units and scalars are the exactly the same" do
      specify { Unit("1 m").should === Unit("1 m")}
      specify { Unit("1 m").should be_same Unit("1 m")}
      specify { Unit("1 m").should be_same_as Unit("1 m")}
    end
    
    context "units are compatible but not identical" do
      specify { Unit("1000 m").should_not === Unit("1 km")}
      specify { Unit("1000 m").should_not be_same Unit("1 km")}
      specify { Unit("1000 m").should_not be_same_as Unit("1 km")}      
    end
    
    context "units are not compatible" do
      specify { Unit("1000 m").should_not === Unit("1 hour")}
      specify { Unit("1000 m").should_not be_same Unit("1 hour")}
      specify { Unit("1000 m").should_not be_same_as Unit("1 hour")}
    end
    
    context "scalars are different" do
      specify { Unit("1 m").should_not === Unit("2 m")}
      specify { Unit("1 m").should_not be_same Unit("2 m")}
      specify { Unit("1 m").should_not be_same_as Unit("2 m")}      
    end
  end
  
  context "Comparisons" do
    context "compatible units can be compared" do
      specify { Unit("1 m").should < Unit("2 m")}
      specify { Unit("2 m").should > Unit("1 m")}
      specify { Unit("1 m").should < Unit("1 mi")}
      specify { Unit("2 m").should > Unit("1 ft")}
#      specify { Unit("70 tempF").should > Unit("10 degC")}
    end
    
    context "incompatible units cannot be compared" do
      specify { expect { Unit("1 m") < Unit("1 liter")}.to raise_error(ArgumentError,"Incompatible Units (m !~ l)")}
      specify { expect { Unit("1 kg") > Unit("60 mph")}.to raise_error(ArgumentError,"Incompatible Units (kg !~ mph)")}
    end
  end
  
end

describe "Unit Conversions" do
  
  context "between compatible units" do
    specify { Unit("1 s").to("ns").should == Unit("1e9 ns")}
    specify { Unit("1 s").convert_to("ns").should == Unit("1e9 ns")}
    specify { (Unit("1 s") >> "ns").should == Unit("1e9 ns")}

    specify { Unit("1 m").to(Unit("ft")).should be_within(Unit("0.001 ft")).of(Unit("3.28084 ft"))}
  end
  
  context "between incompatible units" do
    specify { expect { Unit("1 s").to("m")}.to raise_error(ArgumentError,"Incompatible Units")}
  end
  
  context "temperature conversions" do
    
  end
end

describe "Unit Math" do
  context "addition" do
    context "between compatible units" do
      specify { (Unit("0 m") + Unit("10 m")).should == Unit("10 m")}
      specify { (Unit("5 kg") + Unit("10 kg")).should == Unit("15 kg")}
    end
    
    context "between a zero unit and another unit" do
      specify { (Unit("0 kg") + Unit("10 m")).should == Unit("10 m")}
      specify { (Unit("0 m") + Unit("10 kg")).should == Unit("10 kg")}
    end
    
    context "between incompatible units" do
      specify { expect {Unit("10 kg") + Unit("10 m")}.to raise_error(ArgumentError)}
      specify { expect {Unit("10 m") + Unit("10 kg")}.to raise_error(ArgumentError)}
    end

    context "a number from a unit" do
      specify { expect { Unit("10 kg") + 1 }.to raise_error(ArgumentError)}
      specify { expect { 10 + Unit("10 kg") }.to raise_error(ArgumentError)}
    end
    
  end 
  
  context "subtracting" do
    context "compatible units" do
      specify { (Unit("0 m") - Unit("10 m")).should == Unit("-10 m")}
      specify { (Unit("5 kg") - Unit("10 kg")).should == Unit("-5 kg")}
    end
    
    context "a unit from a zero unit" do
      specify { (Unit("0 kg") - Unit("10 m")).should == Unit("-10 m")}
      specify { (Unit("0 m") - Unit("10 kg")).should == Unit("-10 kg")}
    end
    
    context "incompatible units" do
      specify { expect {Unit("10 kg") - Unit("10 m")}.to raise_error(ArgumentError)}
      specify { expect {Unit("10 m") - Unit("10 kg")}.to raise_error(ArgumentError)}
    end
    
    context "a number from a unit" do
      specify { expect { Unit("10 kg") - 1 }.to raise_error(ArgumentError)}
      specify { expect { 10 - Unit("10 kg") }.to raise_error(ArgumentError)}
    end
    
  end
  
  context "multiplication" do
    context "between compatible units" do
      specify { (Unit("0 m") * Unit("10 m")).should == Unit("0 m^2")}
      specify { (Unit("5 kg") * Unit("10 kg")).should == Unit("50 kg^2")}
    end
        
    context "between incompatible units" do
      specify { (Unit("0 m") * Unit("10 kg")).should == Unit("0 kg*m")}
      specify { (Unit("5 m") * Unit("10 kg")).should == Unit("50 kg*m")}
    end
    
    context "by a temperature" do
      specify { expect { Unit("5 kg") * Unit("100 tempF")}.to raise_exception(ArgumentError) }
    end

    context "by a number" do
      specify { (10 * Unit("5 kg")).should == Unit("50 kg")}
    end
    
  end
  
  context "divide" do
    context "compatible units" do
      specify { (Unit("0 m") / Unit("10 m")).should == Unit("0")}
      specify { (Unit("5 kg") / Unit("10 kg")).should == (1/2)}
    end
        
    context "incompatible units" do
      specify { (Unit("0 m") / Unit("10 kg")).should == Unit("0 m/kg")}
      specify { (Unit("5 m") / Unit("10 kg")).should == Unit("1/2 m/kg")}
    end
    
    context "by a temperature" do
      specify { expect { Unit("5 kg") / Unit("100 tempF")}.to raise_exception(ArgumentError) }
    end

    context "by a number" do
      specify { (10 / Unit("5 kg")).should == Unit("2 1/kg")}
    end
    
    context "by zero" do
      specify { expect { Unit("10 m") / 0}.to raise_error(ZeroDivisionError)}
      specify { expect { Unit("10 m") / Unit("0 m")}.to raise_error(ZeroDivisionError)}
      specify { expect { Unit("10 m") / Unit("0 kg")}.to raise_error(ZeroDivisionError)}
    end
  end
  
  context "exponentiation" do
    context "between compatible units" do
      
    end
    
    context "between incompatible units" do
      
    end
    
  end
end