require_relative "spec_helper"

module RubyUnits

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
          tempC.definition  = Unit.new('1 tempK')
        end
        
        temp_convert_factor = Rational(2501999792983609,4503599627370496) # approximates 1/1.8
        
        Unit.define('tempF') do |tempF|
          tempF.definition  = Unit.new(temp_convert_factor, 'tempK')
        end

        Unit.define('tempR') do |tempR|
          tempR.definition  = Unit.new('1 tempF')
        end
      end
      
      describe "Unit.new('100 tC')" do
        subject {Unit.new("100 tC")}
        its(:scalar) {should be_within(0.001).of 100}
        its(:units) {should == "tC"}
        its(:kind) {should == :temperature}
        it {is_expected.to be_temperature}
        it {is_expected.to be_degree}
        it {is_expected.not_to be_base}
        it {is_expected.not_to be_unitless}
        it {is_expected.not_to be_zero}
        its(:base) {should be_within(Unit.new("0.01 degK")).of Unit.new("373.15 tempK")}
        its(:temperature_scale) {should == "degC"}
      end
      
      context "between temperature scales" do
        # note that 'temp' units are for temperature readings on a scale, while 'deg' units are used to represent
        # differences between temperatures, offsets, or other differential temperatures.
        
        specify { expect(Unit.new("100 tC")).to be_within(Unit.new("0.001 degK")).of(Unit.new("373.15 tempK")) }
        specify { expect(Unit.new("0 tC")).to be_within(Unit.new("0.001 degK")).of(Unit.new("273.15 tempK")) }
        specify { expect(Unit.new("37 tC")).to be_within(Unit.new("0.01 degK")).of(Unit.new("310.15 tempK"))}
        specify { expect(Unit.new("-273.15 tC")).to eq(Unit.new("0 tempK")) }
        
        specify { expect(Unit.new("212 tF")).to be_within(Unit.new("0.001 degK")).of(Unit.new("373.15 tempK")) }
        specify { expect(Unit.new("32 tF")).to be_within(Unit.new("0.001 degK")).of(Unit.new("273.15 tempK")) }
        specify { expect(Unit.new("98.6 tF")).to be_within(Unit.new("0.01 degK")).of(Unit.new("310.15 tempK"))}
        specify { expect(Unit.new("-459.67 tF")).to eq(Unit.new("0 tempK")) }

        specify { expect(Unit.new("671.67 tR")).to be_within(Unit.new("0.001 degK")).of(Unit.new("373.15 tempK")) }
        specify { expect(Unit.new("491.67 tR")).to be_within(Unit.new("0.001 degK")).of(Unit.new("273.15 tempK")) }
        specify { expect(Unit.new("558.27 tR")).to be_within(Unit.new("0.01 degK")).of(Unit.new("310.15 tempK"))}
        specify { expect(Unit.new("0 tR")).to eq(Unit.new("0 tempK")) }
        
        specify { expect(Unit.new("100 tK").convert_to("tempC")).to be_within(Unit.new("0.01 degC")).of(Unit.new("-173.15 tempC"))}
        specify { expect(Unit.new("100 tK").convert_to("tempF")).to be_within(Unit.new("0.01 degF")).of(Unit.new("-279.67 tempF"))}
        specify { expect(Unit.new("100 tK").convert_to("tempR")).to be_within(Unit.new("0.01 degR")).of(Unit.new("180 tempR"))}
      end

    end
  end
  
end
