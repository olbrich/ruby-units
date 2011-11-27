require File.dirname(__FILE__) + '/../spec_helper'

describe Unit.base_units do
  it {should be_a Array}
  it {should have(14).elements}
  %w{kilogram meter second Ampere degK tempK mole candela each dollar steradian radian decibel byte}.each do |u|
    it {should include(Unit(u))}
  end
end


describe "Create some simple units" do

  describe Unit("0") do
    it {should be_a Numeric}
    it {should be_an_instance_of Unit}
    its(:scalar) {should === 0}
    its(:scalar) {should be_an Integer}
    its(:units) {should be_empty}
    its(:kind) {should == :unitless}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should be_base}
    it {should be_unitless}
    it {should be_zero}
    its(:base) {should == subject}  
  end

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
    it {should_not be_zero}
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
    it {should_not be_zero}
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
    it {should_not be_zero}
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
    it {should_not be_zero}
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
    it {should_not be_zero}
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
    it {should_not be_zero}
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
    it {should_not be_zero}
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
    it {should_not be_zero}
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
    it {should_not be_zero}
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
    it {should_not be_zero}
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
    it {should_not be_zero}
    its(:base) {should be_a(Numeric)}
    its(:temperature_scale) {should be_nil}
  end

  describe Unit("100 degC") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_within(0.001).of 100}
    its(:units) {should == "degC"}
    its(:kind) {should == :temperature}
    it {should_not be_temperature}
    it {should be_degree}
    it {should_not be_base}
    it {should_not be_unitless}
    its(:base) {should be_within(Unit("0.01 degK")).of Unit("100 degK")}
  end
      
  describe Unit("75%") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_an Integer}
    its(:units) {should == "%"}
    its(:kind) {should == :unitless}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should_not be_base}
    it {should_not be_unitless}
    it {should_not be_zero}
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
    it {should_not be_zero}
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
    it {should_not be_zero}
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
    it {should_not be_zero}
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
    it {should_not be_zero}
    its(:base) {should be_a Numeric}
    its(:temperature_scale) {should be_nil}    
  end

  describe Unit("1/2 kg/m") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_an Rational}
    its(:units) {should == "kg/m"}
    its(:kind) {should be_nil}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should be_base}
    it {should_not be_unitless}
    it {should_not be_zero}
    its(:base) {should be_a Numeric}
    its(:temperature_scale) {should be_nil}    
  end
  
  describe Unit("1:23:45") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_an Rational}
    its(:units) {should == "h"}
    its(:kind) {should == :time}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should_not be_base}
    it {should_not be_unitless}
    it {should_not be_zero}
    its(:base) {should be_a Numeric}
    its(:temperature_scale) {should be_nil}    
  end

  # also  '1 hours as minutes'
  #       '1 hour to minutes'
  describe Unit.parse("1 hour in minutes") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_an Integer}
    its(:units) {should == "min"}
    its(:kind) {should == :time}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should_not be_base}
    it {should_not be_unitless}
    it {should_not be_zero}
    its(:base) {should be_a Numeric}
    its(:temperature_scale) {should be_nil}    
  end

  describe Unit.new("1 attoparsec/microfortnight") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_an Integer}
    its(:units) {should == "apc/ufortnight"}
    its(:kind) {should == :speed}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should_not be_base}
    it {should_not be_unitless}
    it {should_not be_zero}
    its(:base) {should be_a Numeric}
    its(:temperature_scale) {should be_nil}
    it { subject.convert_to("in/s").should be_within(Unit("0.0001 in/s")).of(Unit("1.0043269330917 in/s"))}
  end
  
  describe Unit.new("1 F") do
    it {should be_an_instance_of Unit}
    its(:scalar) {should be_an Integer}
    its(:units) {should == "F"}
    its(:kind) {should == :capacitance}
    it {should_not be_temperature}
    it {should_not be_degree}
    it {should_not be_base}
    it {should_not be_unitless}
    it {should_not be_zero}
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
  
  specify "no unhandled classes" do
    expect {Unit(STDIN)}.to raise_error(ArgumentError,"Invalid Unit Format")
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
    expect {Unit("-500/9 tempR")}.to raise_error(ArgumentError,"Temperatures must not be less than absolute zero")
  end

end

describe Unit do
  it "is a subclass of Numeric" do
     described_class.should < Numeric
  end
  
  it "is Comparable" do 
    described_class.should < Comparable
  end
  
  describe "#defined?" do
    it "should return true when asked about a defined unit" do
      Unit.defined?("meter").should be_true
    end
    it "should return false when asked about a unit that is not defined" do
      Unit.defined?("doohickey").should be_false
    end
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
      specify { Unit("70 tempF").should > Unit("10 degC")}
      specify { Unit("1 m").should > 0 }
    end
    
    context "incompatible units cannot be compared" do
      specify { expect { Unit("1 m") < Unit("1 liter")}.to raise_error(ArgumentError,"Incompatible Units (m !~ l)")}
      specify { expect { Unit("1 kg") > Unit("60 mph")}.to raise_error(ArgumentError,"Incompatible Units (kg !~ mph)")}
    end
  end
  
end

describe "Unit Conversions" do
  
  context "between compatible units" do
    specify { Unit("1 s").convert_to("ns").should == Unit("1e9 ns")}
    specify { Unit("1 s").convert_to("ns").should == Unit("1e9 ns")}
    specify { (Unit("1 s") >> "ns").should == Unit("1e9 ns")}

    specify { Unit("1 m").convert_to(Unit("ft")).should be_within(Unit("0.001 ft")).of(Unit("3.28084 ft"))}
  end
  
  context "between incompatible units" do
    specify { expect { Unit("1 s").convert_to("m")}.to raise_error(ArgumentError,"Incompatible Units")}
  end
  
  context "given bad input" do
    specify { expect { Unit("1 m").convert_to("random string")}.to raise_error(ArgumentError,"'random string' Unit not recognized")}
    specify { expect { Unit("1 m").convert_to(STDOUT)}.to raise_error(ArgumentError,"Unknown target units")}
  end
  
  context "between temperature scales" do
    # note that 'temp' units are for temperature readings on a scale, while 'deg' units are used to represent
    # differences between temperatures, offsets, or other differential temperatures.
    
    specify { Unit("100 tempC").should be_within(Unit("0.001 degK")).of(Unit("373.15 tempK")) }
    specify { Unit("0 tempC").should be_within(Unit("0.001 degK")).of(Unit("273.15 tempK")) }
    specify { Unit("37 tempC").should be_within(Unit("0.01 degK")).of(Unit("310.15 tempK"))}
    specify { Unit("-273.15 tempC").should == Unit("0 tempK") }
    
    specify { Unit("212 tempF").should be_within(Unit("0.001 degK")).of(Unit("373.15 tempK")) }
    specify { Unit("32 tempF").should be_within(Unit("0.001 degK")).of(Unit("273.15 tempK")) }
    specify { Unit("98.6 tempF").should be_within(Unit("0.01 degK")).of(Unit("310.15 tempK"))}
    specify { Unit("-459.67 tempF").should == Unit("0 tempK") }

    specify { Unit("671.67 tempR").should be_within(Unit("0.001 degK")).of(Unit("373.15 tempK")) }
    specify { Unit("491.67 tempR").should be_within(Unit("0.001 degK")).of(Unit("273.15 tempK")) }
    specify { Unit("558.27 tempR").should be_within(Unit("0.01 degK")).of(Unit("310.15 tempK"))}
    specify { Unit("0 tempR").should == Unit("0 tempK") }
    
    specify { Unit("100 tempK").convert_to("tempC").should be_within(U"0.01 degC").of(Unit("-173.15 tempC"))}
    specify { Unit("100 tempK").convert_to("tempF").should be_within(U"0.01 degF").of(Unit("-279.67 tempF"))}
    specify { Unit("100 tempK").convert_to("tempR").should be_within(U"0.01 degR").of(Unit("180 tempR"))}
            
    specify { Unit("1 degC").should == Unit("1 degK")}
    specify { Unit("1 degF").should == Unit("1 degR")}
    specify { Unit("1 degC").should == Unit("1.8 degR")}
    specify { Unit("1 degF").should be_within(Unit("0.001 degK")).of(Unit("0.5555 degK"))}
  end
  
  context "reported bugs" do
    specify { (Unit("189 Mtonne") * Unit("1189 g/tonne")).should == Unit("224721 tonne") }
    specify { (Unit("189 Mtonne") * Unit("1189 g/tonne")).convert_to("tonne").should == Unit("224721 tonne") }
  end
end

describe "Unit Math" do
  context "operators:" do
    context "addition (+)" do
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
      
      context "between two temperatures" do
        specify { expect {(Unit("100 tempK") + Unit("100 tempK"))}.to raise_error(ArgumentError,"Cannot add two temperatures") }
      end
      
      context "between a temperature and a degree" do
        specify { (Unit("100 tempK") + Unit("100 degK")).should == Unit("200 tempK") }
      end

      context "between a degree and a temperature" do
        specify { (Unit("100 degK") + Unit("100 tempK")).should == Unit("200 tempK") }
      end
    
    end 
  
    context "subtracting (-)" do
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

      context "between two temperatures" do
        specify { (Unit("100 tempK") - Unit("100 tempK")).should == Unit("0 degK") }
      end
      
      context "between a temperature and a degree" do
        specify { (Unit("100 tempK") - Unit("100 degK")).should == Unit("0 tempK") }
      end

      context "between a degree and a temperature" do
        specify { expect {(Unit("100 degK") - Unit("100 tempK"))}.to raise_error(ArgumentError,"Cannot subtract a temperature from a differential degree unit")}
      end
    
    end
  
    context "multiplying (*)" do
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
  
    context "dividing (/)" do
      context "compatible units" do
        specify { (Unit("0 m") / Unit("10 m")).should == Unit(0)}
        specify { (Unit("5 kg") / Unit("10 kg")).should == Rational(1,2)}
      end
        
      context "incompatible units" do
        specify { (Unit("0 m") / Unit("10 kg")).should == Unit("0 m/kg")}
        specify { (Unit("5 m") / Unit("10 kg")).should == Unit("1/2 m/kg")}
      end
    
      context "by a temperature" do
        specify { expect { Unit("5 kg") / Unit("100 tempF")}.to raise_exception(ArgumentError) }
      end

      context "a number by a unit" do
        specify { (10 / Unit("5 kg")).should == Unit("2 1/kg")}
      end

      context "a unit by a number" do
        specify { (Unit("5 kg") / 2).should == Unit("2.5 kg")}
      end
    
      context "by zero" do
        specify { expect { Unit("10 m") / 0}.to raise_error(ZeroDivisionError)}
        specify { expect { Unit("10 m") / Unit("0 m")}.to raise_error(ZeroDivisionError)}
        specify { expect { Unit("10 m") / Unit("0 kg")}.to raise_error(ZeroDivisionError)}
      end
    end
  
    context "exponentiating (**)" do
    
      specify "a temperature raises an execption" do
        expect { Unit("100 tempK")**2 }.to raise_error(ArgumentError,"Cannot raise a temperature to a power")
      end
    
      context Unit("0 m") do
        it { (subject**1).should == subject }
        it { (subject**2).should == subject }
      end

      context Unit("1 m") do
        it { (subject**0).should == 1 }
        it { (subject**1).should == subject }
        it { (subject**(-1)).should == 1/subject }
        it { (subject**(2)).should == Unit("1 m^2")}
        it { (subject**(-2)).should == Unit("1 1/m^2")}
        specify { expect { subject**(1/2)}.to raise_error(ArgumentError, "Illegal root")}
          # because 1 m^(1/2) doesn't make any sense
        specify { expect { subject**(Complex(1,1))}.to raise_error(ArgumentError, "exponentiation of complex numbers is not yet supported.")}
        specify { expect { subject**(Unit("1 m"))}.to raise_error(ArgumentError, "Invalid Exponent")}
      end
    
      context Unit("1 m^2") do
        it { (subject**(Rational(1,2))).should == Unit("1 m")}
        it { (subject**(0.5)).should == Unit("1 m")}
      
        specify { expect { subject**(0.12345) }.to raise_error(ArgumentError,"Not a n-th root (1..9), use 1/n")}
        specify { expect { subject**("abcdefg") }.to raise_error(ArgumentError,"Invalid Exponent")}
      end
    
    end
  
    context "modulo (%)" do
      context "compatible units" do
        specify { (Unit("2 m") % Unit("1 m")).should == 0 }
        specify { (Unit("5 m") % Unit("2 m")).should == 1 }
      end
    
      specify "incompatible units raises an exception" do 
        expect { Unit("1 m") % Unit("1 kg")}.to raise_error(ArgumentError,"Incompatible Units")
      end
    end
  end
  
  context "#power" do
    subject { Unit("1 m") }
    it "raises an exception when passed a Float argument" do
      expect {subject.power(1.5)}.to raise_error(ArgumentError,"Exponent must an Integer")
    end
    it "raises an exception when passed a Rational argument" do
      expect {subject.power(Rational(1,2))}.to raise_error(ArgumentError,"Exponent must an Integer")
    end
    it "raises an exception when passed a Complex argument" do
      expect {subject.power(Complex(1,2))}.to raise_error(ArgumentError,"Exponent must an Integer")
    end
    it "raises an exception when called on a temperature unit" do
      expect { Unit("100 tempC").power(2)}.to raise_error(ArgumentError,"Cannot raise a temperature to a power")
    end
    
    specify { (subject.power(-1)).should == Unit("1 1/m") }    
    specify { (subject.power(0)).should == 1 }
    specify { (subject.power(1)).should == subject }
    specify { (subject.power(2)).should == Unit("1 m^2") }
    
  end
  
  context "#root" do
    subject { Unit("1 m") }
    it "raises an exception when passed a Float argument" do
      expect {subject.root(1.5)}.to raise_error(ArgumentError,"Exponent must an Integer")
    end
    it "raises an exception when passed a Rational argument" do
      expect {subject.root(Rational(1,2))}.to raise_error(ArgumentError,"Exponent must an Integer")
    end
    it "raises an exception when passed a Complex argument" do
      expect {subject.root(Complex(1,2))}.to raise_error(ArgumentError,"Exponent must an Integer")
    end
    it "raises an exception when called on a temperature unit" do
      expect { Unit("100 tempC").root(2)}.to raise_error(ArgumentError,"Cannot take the root of a temperature")
    end
    
    specify { (Unit("1 m^2").root(-2)).should == Unit("1 1/m") }
    specify { (subject.root(-1)).should == Unit("1 1/m") }    
    specify { expect {(subject.root(0))}.to raise_error(ArgumentError, "0th root undefined")}
    specify { (subject.root(1)).should == subject }
    specify { (Unit("1 m^2").root(2)).should == Unit("1 m") }
    
  end
  
  context "#inverse" do
    specify { Unit("1 m").inverse.should == Unit("1 1/m") }
    specify { expect {Unit("100 tempK").inverse}.to raise_error(ArgumentError,"Cannot divide with temperatures") }
  end
  
  context "convert to scalars" do
    specify {Unit("10").to_i.should be_kind_of(Integer)}
    specify { expect { Unit("10 m").to_i }.to raise_error(RuntimeError,"Cannot convert '10 m' to Integer unless unitless.  Use Unit#scalar") }

    specify {Unit("10.0").to_f.should be_kind_of(Float)}
    specify { expect { Unit("10.0 m").to_f }.to raise_error(RuntimeError,"Cannot convert '10 m' to Float unless unitless.  Use Unit#scalar") }

    specify {Unit("1+1i").to_c.should be_kind_of(Complex)}
    specify { expect { Unit("1+1i m").to_c }.to raise_error(RuntimeError,"Cannot convert '1.0+1.0i m' to Complex unless unitless.  Use Unit#scalar") }

    specify {Unit("3/7").to_r.should be_kind_of(Rational)}
    specify { expect { Unit("3/7 m").to_r }.to raise_error(RuntimeError,"Cannot convert '3/7 m' to Rational unless unitless.  Use Unit#scalar") }
    
  end
  
  context "absolute value (#abs)" do
    context "of a unitless unit" do
      specify "returns the absolute value of the scalar" do
        Unit("-10").abs.should == 10
      end
    end
    
    context "of a unit" do
      specify "returns a unit with the absolute value of the scalar" do
        Unit("-10 m").abs.should == Unit("10 m")
      end
    end
  end
  
  context "#ceil" do
    context "of a unitless unit" do
      specify "returns the ceil of the scalar" do
        Unit("10.1").ceil.should == 11
      end
    end
    
    context "of a unit" do
      specify "returns a unit with the ceil of the scalar" do
        Unit("10.1 m").ceil.should == Unit("11 m")
      end
    end
  end

  context "#floor" do
    context "of a unitless unit" do
      specify "returns the floor of the scalar" do
        Unit("10.1").floor.should == 10
      end
    end
    
    context "of a unit" do
      specify "returns a unit with the floor of the scalar" do
        Unit("10.1 m").floor.should == Unit("10 m")
      end
    end
  end

  context "#round" do
    context "of a unitless unit" do
      specify "returns the round of the scalar" do
        Unit("10.5").round.should == 11
      end
    end
    
    context "of a unit" do
      specify "returns a unit with the round of the scalar" do
        Unit("10.5 m").round.should == Unit("11 m")
      end
    end
  end
  
  context "#truncate" do
    context "of a unitless unit" do
      specify "returns the truncate of the scalar" do
        Unit("10.5").truncate.should == 10
      end
    end
    
    context "of a unit" do
      specify "returns a unit with the truncate of the scalar" do
        Unit("10.5 m").truncate.should == Unit("10 m")
      end
    end
  end
  
  context '#zero?' do
    it "is true when the scalar is zero on the base scale" do
      Unit("0").should be_zero
      Unit("0 mm").should be_zero
      Unit("-273.15 tempC").should be_zero
    end

    it "is false when the scalar is not zero" do
      Unit("1").should_not be_zero
      Unit("1 mm").should_not be_zero
      Unit("0 tempC").should_not be_zero
    end
  end
  
  context '#succ' do
    specify { Unit("1").succ.should == Unit("2")}
    specify { Unit("1 mm").succ.should == Unit("2 mm")}
    specify { Unit("1 mm").next.should == Unit("2 mm")}
    specify { Unit("-1 mm").succ.should == Unit("0 mm")}
    specify { expect {Unit("1.5 mm").succ}.to raise_error(ArgumentError,"Non Integer Scalar")}
  end

  context '#pred' do
    specify { Unit("1").pred.should == Unit("0")}
    specify { Unit("1 mm").pred.should == Unit("0 mm")}
    specify { Unit("-1 mm").pred.should == Unit("-2 mm")}
    specify { expect {Unit("1.5 mm").pred}.to raise_error(ArgumentError,"Non Integer Scalar")}
  end

  context '#divmod' do
    specify { Unit("5 mm").divmod(Unit("2 mm")).should == [2,1] }
    specify { Unit("1 km").divmod(Unit("2 m")).should == [500,0] }
  end

  context "Time helper functions" do
    before do
      Time.stub!(:now).and_return(Time.utc(2011,10,16))
      DateTime.stub!(:now).and_return(DateTime.civil(2011,10,16))
      Date.stub!(:today).and_return(Date.civil(2011,10,16))
    end
  
    context '#since' do
      specify { Unit("min").since(Time.utc(2001,4,1,0,0,0)).should == Unit("5544000 min")}
      specify { Unit("min").since(DateTime.civil(2001,4,1,0,0,0)).should == Unit("5544000 min")}
      specify { Unit("min").since(Date.civil(2001,4,1)).should == Unit("5544000 min")}
      specify { expect {Unit("min").since("4-1-2001")}.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime")  }
      specify { expect {Unit("min").since(nil)}.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime")  }
    end
    
    context '#before' do
      specify { Unit("5 min").before(Time.now).should == Time.utc(2011,10,15,23,55)}
      specify { Unit("5 min").before(DateTime.now).should == DateTime.civil(2011,10,15,23,55)}
      specify { Unit("5 min").before(Date.today).should == DateTime.civil(2011,10,15,23,55)}
      specify { expect {Unit('5 min').before(nil)}.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime")}
      specify { expect {Unit('5 min').before("12:00")}.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime")}
    end
    
    context '#ago' do
      specify { Unit("5 min").ago.should be_kind_of Time}
      specify { Unit("10000 y").ago.should be_kind_of Time}
      specify { Unit("1 year").ago.should == Time.utc(2010,10,16)}
    end
    
    context '#until' do
      specify { Unit("min").until(Date.civil(2011,10,17)).should == Unit("1440 min")}
      specify { Unit("min").until(DateTime.civil(2011,10,21)).should == Unit("7200 min")}
      specify { Unit("min").until(Time.utc(2011,10,21)).should == Unit("7200 min")}
      specify { expect {Unit('5 min').until(nil)}.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime")}
      specify { expect {Unit('5 min').until("12:00")}.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime")}
    end
    
    context '#from' do
      specify { Unit("1 day").from(Date.civil(2011,10,17)).should == Date.civil(2011,10,18)}
      specify { Unit("5 min").from(DateTime.civil(2011,10,21)).should == DateTime.civil(2011,10,21,00,05)}
      specify { Unit("5 min").from(Time.utc(2011,10,21)).should == Time.utc(2011,10,21,00,05)}
      specify { expect {Unit('5 min').from(nil)}.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime")}
      specify { expect {Unit('5 min').from("12:00")}.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime")}
    end
  
  end
  
  

end

describe "Unit Output formatting" do
  context Unit("10.5 m/s^2") do
    specify { subject.to_s.should == "10.5 m/s^2" }
    specify { subject.to_s("%0.2f").should == "10.50 m/s^2"}
    specify { subject.to_s("%0.2e km/s^2").should == "1.05e-02 km/s^2"}
    specify { subject.to_s("km/s^2").should == "0.0105 km/s^2"}
    specify { subject.to_s(STDOUT).should == "10.5 m/s^2" }
    specify { expect {subject.to_s("random string")}.to raise_error(ArgumentError,"'random' Unit not recognized")}
  end
  
end

describe "Foot-inch conversions" do
  [
    ["76 in", %Q{6'4"}],
    ["77 in", %Q{6'5"}],
    ["78 in", %Q{6'6"}],
    ["79 in", %Q{6'7"}],
    ["80 in", %Q{6'8"}],
    ["87 in", %Q{7'3"}],
    ["88 in", %Q{7'4"}],
    ["89 in", %Q{7'5"}]
    ].each do |inches, feet|
    specify { Unit(inches).convert_to("ft").should == Unit(feet)}
    specify { Unit(inches).to_s(:ft).should == feet}
  end
end

describe "pound-ounce conversions" do
  [
    ["76 oz", "4 lbs, 12 oz"],
    ["77 oz", "4 lbs, 13 oz"],
    ["78 oz", "4 lbs, 14 oz"],
    ["79 oz", "4 lbs, 15 oz"],
    ["80 oz", "5 lbs, 0 oz"],
    ["87 oz", "5 lbs, 7 oz"],
    ["88 oz", "5 lbs, 8 oz"],
    ["89 oz", "5 lbs, 9 oz"]
    ].each do |ounces, pounds|
    specify { Unit(ounces).convert_to("lbs").should == Unit(pounds)}
    specify { Unit(ounces).to_s(:lbs).should == pounds}
  end  
end

describe Unit do
  describe "definition" do
    
    context "The requested unit is defined" do
      before(:each) do
        @definition = Unit.definition('mph')
      end
      
      it "should return a Unit::Definition" do
        @definition.should be_instance_of(Unit::Definition)
      end
      
      specify { @definition.name.should == "<mph>"}
      specify { @definition.aliases.should == %w{mph}}
      specify { @definition.numerator.should == ['<meter>'] }
      specify { @definition.denominator.should == ['<second>'] }
      specify { @definition.kind.should == :speed }
      specify { @definition.scalar.should === 0.44704}
    end
    
    context "The requested unit is not defined" do
      it "should return nil" do
        Unit.definition("doohickey").should be_nil
      end
    end  
  end
  
  describe "define" do
    describe "a new unit" do
      before(:each) do
        @jiffy = Unit::Definition.new("jiffy") do |jiffy|
          jiffy.scalar = (1/100)
          jiffy.aliases = %w{jif}
          jiffy.numerator = ["<second>"]
          jiffy.kind = :time
        end
        Unit.define(@jiffy)
        Unit.setup
      end
    
      describe "Unit('1e6 jiffy')" do
        # do this because the unit is not defined at the time this file is parsed, so it fails
        subject {Unit("1e6 jiffy")}
      
        it {should be_a Numeric}
        it {should be_an_instance_of Unit}
        its(:scalar) {should == 1e6}
        its(:scalar) {should be_an Integer}
        its(:units) {should == "jif"}
        its(:kind) {should == :time}
        it {should_not be_temperature}
        it {should_not be_degree}
        it {should_not be_base}
        it {should_not be_unitless}
        it {should_not be_zero}
        its(:base) {should == Unit("10000 s")}
      end
    
      it "should register the new unit" do
        Unit.defined?('jiffy').should be_true
      end
    end
    
    describe "an existing unit again" do
      before(:each) do
        @cups = Unit.definition('cup')
        @cups.aliases = %w{cup cu cups}
        Unit.define(@cups)
        Unit.setup
      end
    
      describe "Unit('1 cup')" do
        # do this because the unit is going to be redefined
        subject {Unit("1 cup")}
      
        it {should be_a Numeric}
        it {should be_an_instance_of Unit}
        its(:scalar) {should == 1}
        its(:scalar) {should be_an Integer}
        its(:units) {should == "cup"}
        its(:kind) {should == :volume}
        it {should_not be_temperature}
        it {should_not be_degree}
        it {should_not be_base}
        it {should_not be_unitless}
        it {should_not be_zero}
      end
          
    end
    
  end
  
end

