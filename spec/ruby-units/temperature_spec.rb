require File.dirname(__FILE__) + '/../spec_helper'

describe 'temperatures' do
  describe 'redfine display name' do
    before(:all) do
      Unit.redefine!("tempC") do |c|
        c.aliases = %w{tC tempC}
        c.display_name = "tC"
      end

      Unit.redefine!("tempF") do |f|
        f.aliases = %w{tF tempF}
        f.display_name = "tF"
      end

      Unit.redefine!("tempR") do |f|
        f.aliases = %w{tR tempR}
        f.display_name = "tR"
      end

      Unit.redefine!("tempK") do |f|
        f.aliases = %w{tK tempK}
        f.display_name = "tK"
      end
    end
    
    after(:all) do
      #define the temp units back to normal
      Unit.define("tempK") do |unit|
        unit.scalar    = 1
        unit.numerator = %w{<tempK>}
        unit.aliases   = %w{tempK}
        unit.kind      = :temperature
      end
      
      Unit.define('tempC') do |tempC|
        tempC.definition  = Unit('1 tempK')
      end
      
      temp_convert_factor = Rational(2501999792983609,4503599627370496) # approximates 1/1.8
      
      Unit.define('tempF') do |tempF|
        tempF.definition  = Unit(temp_convert_factor, 'tempK')
      end

      Unit.define('tempR') do |tempR|
        tempR.definition  = Unit('1 tempF')
      end
    end
    
    describe "Unit('100 tC')" do
      subject {Unit("100 tC")}
      its(:scalar) {should be_within(0.001).of 100}
      its(:units) {should == "tC"}
      its(:kind) {should == :temperature}
      it {should be_temperature}
      it {should be_degree}
      it {should_not be_base}
      it {should_not be_unitless}
      it {should_not be_zero}
      its(:base) {should be_within(Unit("0.01 degK")).of Unit("373.15 tempK")}
      its(:temperature_scale) {should == "degC"}
    end
    
    context "between temperature scales" do
      # note that 'temp' units are for temperature readings on a scale, while 'deg' units are used to represent
      # differences between temperatures, offsets, or other differential temperatures.
    
      specify { Unit("100 tC").should be_within(Unit("0.001 degK")).of(Unit("373.15 tempK")) }
      specify { Unit("0 tC").should be_within(Unit("0.001 degK")).of(Unit("273.15 tempK")) }
      specify { Unit("37 tC").should be_within(Unit("0.01 degK")).of(Unit("310.15 tempK"))}
      specify { Unit("-273.15 tC").should == Unit("0 tempK") }
    
      specify { Unit("212 tF").should be_within(Unit("0.001 degK")).of(Unit("373.15 tempK")) }
      specify { Unit("32 tF").should be_within(Unit("0.001 degK")).of(Unit("273.15 tempK")) }
      specify { Unit("98.6 tF").should be_within(Unit("0.01 degK")).of(Unit("310.15 tempK"))}
      specify { Unit("-459.67 tF").should == Unit("0 tempK") }

      specify { Unit("671.67 tR").should be_within(Unit("0.001 degK")).of(Unit("373.15 tempK")) }
      specify { Unit("491.67 tR").should be_within(Unit("0.001 degK")).of(Unit("273.15 tempK")) }
      specify { Unit("558.27 tR").should be_within(Unit("0.01 degK")).of(Unit("310.15 tempK"))}
      specify { Unit("0 tR").should == Unit("0 tempK") }
    
      specify { Unit("100 tK").convert_to("tempC").should be_within(U"0.01 degC").of(Unit("-173.15 tempC"))}
      specify { Unit("100 tK").convert_to("tempF").should be_within(U"0.01 degF").of(Unit("-279.67 tempF"))}
      specify { Unit("100 tK").convert_to("tempR").should be_within(U"0.01 degR").of(Unit("180 tempR"))}

      specify { Unit("100 tK").convert_to("tC").should be_within(U"0.01 degC").of(Unit("-173.15 tempC"))}
      specify { Unit("100 tK").convert_to("tF").should be_within(U"0.01 degF").of(Unit("-279.67 tempF"))}
      specify { Unit("100 tK").convert_to("tR").should be_within(U"0.01 degR").of(Unit("180 tempR"))}
    end

    
    
    
  end
end
  
