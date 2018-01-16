require File.dirname(__FILE__) + '/../spec_helper'

describe 'temperatures' do
  describe 'redfine display name' do
    before(:all) do
      Unit.redefine!('tempC') do |c|
        c.aliases = %w[tC tempC]
        c.display_name = 'tC'
      end

      Unit.redefine!('tempF') do |f|
        f.aliases = %w[tF tempF]
        f.display_name = 'tF'
      end

      Unit.redefine!('tempR') do |f|
        f.aliases = %w[tR tempR]
        f.display_name = 'tR'
      end

      Unit.redefine!('tempK') do |f|
        f.aliases = %w[tK tempK]
        f.display_name = 'tK'
      end
    end

    after(:all) do
      # define the temp units back to normal
      Unit.define('tempK') do |unit|
        unit.scalar    = 1
        unit.numerator = %w[<tempK>]
        unit.aliases   = %w[tempK]
        unit.kind      = :temperature
      end

      Unit.define('tempC') do |tempc|
        tempc.definition  = RubyUnits::Unit.new('1 tempK')
      end

      temp_convert_factor = Rational(2_501_999_792_983_609, 4_503_599_627_370_496) # approximates 1/1.8

      Unit.define('tempF') do |tempf|
        tempf.definition  = RubyUnits::Unit.new(temp_convert_factor, 'tempK')
      end

      Unit.define('tempR') do |tempr|
        tempr.definition  = RubyUnits::Unit.new('1 tempF')
      end
    end

    describe "RubyUnits::Unit.new('100 tC')" do
      subject { RubyUnits::Unit.new('100 tC') }

      describe '#scalar' do
        subject { super().scalar }
        it { is_expected.to be_within(0.001).of 100 }
      end

      describe '#units' do
        subject { super().units }
        it { is_expected.to eq('tC') }
      end

      describe '#kind' do
        subject { super().kind }
        it { is_expected.to eq(:temperature) }
      end
      it { is_expected.to be_temperature }
      it { is_expected.to be_degree }
      it { is_expected.not_to be_base }
      it { is_expected.not_to be_unitless }
      it { is_expected.not_to be_zero }

      describe '#base' do
        subject { super().base }
        it { is_expected.to be_within(RubyUnits::Unit.new('0.01 degK')).of RubyUnits::Unit.new('373.15 tempK') }
      end

      describe '#temperature_scale' do
        subject { super().temperature_scale }
        it { is_expected.to eq('degC') }
      end
    end

    context 'between temperature scales' do
      # note that 'temp' units are for temperature readings on a scale, while 'deg' units are used to represent
      # differences between temperatures, offsets, or other differential temperatures.

      specify { expect(RubyUnits::Unit.new('100 tC')).to be_within(RubyUnits::Unit.new('0.001 degK')).of(RubyUnits::Unit.new('373.15 tempK')) }
      specify { expect(RubyUnits::Unit.new('0 tC')).to be_within(RubyUnits::Unit.new('0.001 degK')).of(RubyUnits::Unit.new('273.15 tempK')) }
      specify { expect(RubyUnits::Unit.new('37 tC')).to be_within(RubyUnits::Unit.new('0.01 degK')).of(RubyUnits::Unit.new('310.15 tempK')) }
      specify { expect(RubyUnits::Unit.new('-273.15 tC')).to eq(RubyUnits::Unit.new('0 tempK')) }

      specify { expect(RubyUnits::Unit.new('212 tF')).to be_within(RubyUnits::Unit.new('0.001 degK')).of(RubyUnits::Unit.new('373.15 tempK')) }
      specify { expect(RubyUnits::Unit.new('32 tF')).to be_within(RubyUnits::Unit.new('0.001 degK')).of(RubyUnits::Unit.new('273.15 tempK')) }
      specify { expect(RubyUnits::Unit.new('98.6 tF')).to be_within(RubyUnits::Unit.new('0.01 degK')).of(RubyUnits::Unit.new('310.15 tempK')) }
      specify { expect(RubyUnits::Unit.new('-459.67 tF')).to eq(RubyUnits::Unit.new('0 tempK')) }

      specify { expect(RubyUnits::Unit.new('671.67 tR')).to be_within(RubyUnits::Unit.new('0.001 degK')).of(RubyUnits::Unit.new('373.15 tempK')) }
      specify { expect(RubyUnits::Unit.new('491.67 tR')).to be_within(RubyUnits::Unit.new('0.001 degK')).of(RubyUnits::Unit.new('273.15 tempK')) }
      specify { expect(RubyUnits::Unit.new('558.27 tR')).to be_within(RubyUnits::Unit.new('0.01 degK')).of(RubyUnits::Unit.new('310.15 tempK')) }
      specify { expect(RubyUnits::Unit.new('0 tR')).to eq(RubyUnits::Unit.new('0 tempK')) }

      specify { expect(RubyUnits::Unit.new('100 tK').convert_to('tempC')).to be_within(RubyUnits::Unit.new('0.01 degC')).of(RubyUnits::Unit.new('-173.15 tempC')) }
      specify { expect(RubyUnits::Unit.new('100 tK').convert_to('tempF')).to be_within(RubyUnits::Unit.new('0.01 degF')).of(RubyUnits::Unit.new('-279.67 tempF')) }
      specify { expect(RubyUnits::Unit.new('100 tK').convert_to('tempR')).to be_within(RubyUnits::Unit.new('0.01 degR')).of(RubyUnits::Unit.new('180 tempR')) }

      specify { expect(RubyUnits::Unit.new('32 tF').convert_to('tempC')).to eq(RubyUnits::Unit.new('0 tC')) }
    end
  end
end
