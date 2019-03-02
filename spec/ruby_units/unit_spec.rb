require File.dirname(__FILE__) + '/../spec_helper'
require 'yaml'

describe Unit.base_units do
  it { is_expected.to be_a Array }
  it 'has 14 elements' do
    expect(subject.size).to eq(14)
  end
  %w[kilogram meter second ampere degK tempK mole candela each dollar steradian radian decibel byte].each do |u|
    it { is_expected.to include(RubyUnits::Unit.new(u)) }
  end
end

describe 'Create some simple units' do
  # zero string
  describe RubyUnits::Unit.new('0') do
    it { is_expected.to be_a Numeric }
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be === 0 }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to be_empty }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:unitless) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.to be_unitless }
    it { is_expected.to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to eq(subject) }
    end
  end

  # non-zero string
  describe RubyUnits::Unit.new('1') do
    it { is_expected.to be_a Numeric }
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be === 1 }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to be_empty }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:unitless) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to eq(subject) }
    end
  end

  # numeric
  describe RubyUnits::Unit.new(1) do
    it { is_expected.to be_a Numeric }
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be === 1 }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to be_empty }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:unitless) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to eq(subject) }
    end
  end

  # rational
  describe RubyUnits::Unit.new(Rational(1, 2)) do
    it { is_expected.to be_a Numeric }
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be === Rational(1, 2) }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_a Rational }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to be_empty }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:unitless) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to eq(subject) }
    end
  end

  # float
  describe RubyUnits::Unit.new(0.5) do
    it { is_expected.to be_a Numeric }
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be === 0.5 }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_a Float }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to be_empty }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:unitless) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to eq(subject) }
    end
  end

  # complex
  describe RubyUnits::Unit.new(Complex(1, 1)) do
    it { is_expected.to be_a Numeric }
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be === Complex(1, 1) }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_a Complex }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to be_empty }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:unitless) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to eq(subject) }
    end
  end

  describe RubyUnits::Unit.new('1+1i m') do
    it { is_expected.to be_a Numeric }
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be === Complex(1, 1) }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_a Complex }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('m') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:length) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to eq(subject) }
    end
  end

  # scalar and unit
  describe RubyUnits::Unit.new('1 mm') do
    it { is_expected.to be_a Numeric }
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to eq(1) }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('mm') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:length) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.not_to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to eq(RubyUnits::Unit.new('0.001 m')) }
    end
  end

  # with a zero power
  describe RubyUnits::Unit.new('1 m^0') do
    it { is_expected.to be_a Numeric }
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to eq(1) }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:unitless) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to eq(RubyUnits::Unit.new('1')) }
    end
  end

  # unit only
  describe RubyUnits::Unit.new('mm') do
    it { is_expected.to be_a Numeric }
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to eq(1) }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('mm') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:length) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.not_to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to eq(RubyUnits::Unit.new('0.001 m')) }
    end
  end

  # Compound unit
  describe RubyUnits::Unit.new('1 N*m') do
    it { is_expected.to be_a Numeric }
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to eq(1) }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('N*m') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:energy) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.not_to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to eq(RubyUnits::Unit.new('1 kg*m^2/s^2')) }
    end
  end

  # scalar and unit with powers
  describe RubyUnits::Unit.new('10 m/s^2') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to eq(10) }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('m/s^2') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:acceleration) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to eq(RubyUnits::Unit.new('10 m/s^2')) }
    end
  end

  # feet/in form
  ['5 feet 6 inches', '5 feet 6 inch', '5ft 6in', '5 ft 6 in', %(5'6"), %(5' 6")].each do |unit|
    describe unit do
      subject { RubyUnits::Unit.new(unit) }
      it { is_expected.to be_an_instance_of Unit }

      describe '#scalar' do
        subject { super().scalar }
        it { is_expected.to eq(5.5) }
      end

      describe '#units' do
        subject { super().units }
        it { is_expected.to eq('ft') }
      end

      describe '#kind' do
        subject { super().kind }
        it { is_expected.to eq(:length) }
      end
      it { is_expected.not_to be_temperature }
      it { is_expected.not_to be_degree }
      it { is_expected.not_to be_base }
      it { is_expected.not_to be_unitless }
      it { is_expected.not_to be_zero }

      describe '#base' do
        subject { super().base }
        it { is_expected.to be_within(RubyUnits::Unit.new('0.01 m')).of RubyUnits::Unit.new('1.6764 m') }
      end
      specify { expect(subject.to_s(:ft)).to eq(%(5'6")) }
    end
  end

  # pound/ounces form
  describe RubyUnits::Unit.new('6lbs 5oz') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_within(0.001).of 6.312 }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('lbs') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:mass) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.not_to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_within(RubyUnits::Unit.new('0.01 kg')).of RubyUnits::Unit.new('2.8633 kg') }
    end
    specify { expect(subject.to_s(:lbs)).to eq('6 lbs, 5 oz') }
  end

  # temperature
  describe RubyUnits::Unit.new('100 tempC') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_within(0.001).of 100 }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('tempC') }
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

  # Time
  describe RubyUnits::Unit.new(Time.now) do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_a(Numeric) }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('s') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:time) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a(Numeric) }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
  end

  # degrees
  describe RubyUnits::Unit.new('100 degC') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_within(0.001).of 100 }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('degC') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:temperature) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.to be_degree }
    it { is_expected.not_to be_base }
    it { is_expected.not_to be_unitless }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_within(RubyUnits::Unit.new('0.01 degK')).of RubyUnits::Unit.new('100 degK') }
    end
  end

  # percent
  describe RubyUnits::Unit.new('75%') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('%') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:unitless) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.not_to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a(Numeric) }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
  end

  # angle
  describe RubyUnits::Unit.new('180 deg') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_a Numeric }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('deg') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:angle) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.not_to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a(Numeric) }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
  end

  # radians
  describe RubyUnits::Unit.new('1 radian') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_a Numeric }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('rad') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:angle) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a Numeric }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
  end

  # counting
  describe RubyUnits::Unit.new('12 dozen') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('doz') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:unitless) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.not_to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a Numeric }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
  end

  # rational scalar with unit
  describe RubyUnits::Unit.new('1/2 kg') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Rational }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('kg') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:mass) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a Numeric }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
  end

  describe RubyUnits::Unit.new('6/1 lbs') do
    it { is_expected.to be_an_instance_of Unit }
    describe '#to_s' do
      subject { super().to_s }
      it { is_expected.to eq '6 lbs' }
    end
  end

  # rational scalar with compound unit
  describe RubyUnits::Unit.new('1/2 kg/m') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Rational }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('kg/m') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to be_nil }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a Numeric }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
  end

  # rational scalar with numeric modified unit
  describe Unit.new('12.0mg/6.0mL') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Numeric }
      it { is_expected.to eq(12.0 / 6.0) }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq 'mg/ml' }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq :density }
    end

    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.not_to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a Numeric }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
  end

  # time string
  describe RubyUnits::Unit.new('1:23:45,200') do
    it { is_expected.to be_an_instance_of Unit }
    it { is_expected.to eq(RubyUnits::Unit.new('1 h') + RubyUnits::Unit.new('23 min') + RubyUnits::Unit.new('45 seconds') + RubyUnits::Unit.new('200 usec')) }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Rational }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('h') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:time) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.not_to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a Numeric }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
  end

  # also  '1 hours as minutes'
  #       '1 hour to minutes'
  describe Unit.parse('1 hour in minutes') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to eq 60 }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('min') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:time) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.not_to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a Numeric }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
  end

  # funky unit
  describe RubyUnits::Unit.new('1 attoparsec/microfortnight') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('apc/ufortnight') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:speed) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.not_to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a Numeric }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
    it { expect(subject.convert_to('in/s')).to be_within(RubyUnits::Unit.new('0.0001 in/s')).of(RubyUnits::Unit.new('1.0043269330917 in/s')) }
  end

  # Farads
  describe RubyUnits::Unit.new('1 F') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('F') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:capacitance) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.not_to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a Numeric }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
  end

  describe RubyUnits::Unit.new('1 m^2 s^-2') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('m^2/s^2') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:radiation) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a Numeric }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
  end

  describe RubyUnits::Unit.new(1, 'm^2', 's^2') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('m^2/s^2') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:radiation) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a Numeric }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
  end

  # scientific notation
  describe RubyUnits::Unit.new('1e6 cells') do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to eq(1e6) }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('cells') }
    end

    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:unitless) }
    end
    it { is_expected.not_to be_temperature }
    it { is_expected.not_to be_degree }
    it { is_expected.not_to be_base }
    it { is_expected.not_to be_unitless }
    it { is_expected.not_to be_zero }

    describe '#base' do
      subject { super().base }
      it { is_expected.to be_a Numeric }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to be_nil }
    end
  end

  # could be m*m
  describe RubyUnits::Unit.new('1 mm') do
    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:length) }
    end
  end

  # could be centi-day
  describe RubyUnits::Unit.new('1 cd') do
    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:luminous_power) }
    end
  end

  # could be milli-inch
  describe RubyUnits::Unit.new('1 min') do
    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:time) }
    end
  end

  # could be femto-tons
  describe RubyUnits::Unit.new('1 ft') do
    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:length) }
    end
  end

  # could be deci-ounce
  describe RubyUnits::Unit.new('1 doz') do
    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:unitless) }
    end
  end

  # create with another unit
  describe 10.to_unit(RubyUnits::Unit.new('1 mm')) do
    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('mm') }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to eq(10) }
    end
  end

  # explicit create
  describe RubyUnits::Unit.new('1 <meter>/<second>') do
    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:speed) }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('m/s') }
    end
  end

  describe RubyUnits::Unit.new('1 <kilogram><meter>/<second><second><second>') do
    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:yank) }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq('kg*m/s^3') }
    end
  end

  # without spaces
  describe RubyUnits::Unit.new('1g') do
    specify { expect(subject).to eq(RubyUnits::Unit.new('1 g')) }
  end

  describe RubyUnits::Unit.new('-1g') do
    specify { expect(subject).to eq(RubyUnits::Unit.new('-1 g')) }
  end

  describe RubyUnits::Unit.new('11/s') do
    specify { expect(subject).to eq(RubyUnits::Unit.new('11 1/s')) }
  end

  describe Unit.new('63.5029318kg') do
    specify { expect(subject).to eq(Unit.new('63.5029318 kg')) }
  end

  # mixed fraction
  describe Unit.new('6 1/2 cups') do
    specify { expect(subject).to eq(Unit.new('13/2 cu')) }
  end

  # mixed fraction
  describe Unit.new('-6-1/2 cups') do
    specify { expect(subject).to eq(Unit.new('-13/2 cu')) }
  end

  describe Unit.new('100 mcg') do
    specify { expect(subject).to eq(Unit.new('100 ug')) }
  end

  describe Unit.new('100 mcL') do
    specify { expect(subject).to eq(Unit.new('100 uL')) }
  end
end

describe 'Unit handles attempts to create bad units' do
  specify 'no empty strings' do
    expect { RubyUnits::Unit.new('') }.to raise_error(ArgumentError, 'No Unit Specified')
  end

  specify 'no blank strings' do
    expect { RubyUnits::Unit.new('   ') }.to raise_error(ArgumentError, 'No Unit Specified')
  end

  specify 'no strings with tabs' do
    expect { RubyUnits::Unit.new("\t") }.to raise_error(ArgumentError, 'No Unit Specified')
  end

  specify 'no strings with newlines' do
    expect { RubyUnits::Unit.new("\n") }.to raise_error(ArgumentError, 'No Unit Specified')
  end

  specify 'no double slashes' do
    expect { RubyUnits::Unit.new('3 s/s/ft') }.to raise_error(ArgumentError, /Unit not recognized/)
  end

  specify 'no pipes or commas' do
    expect { RubyUnits::Unit.new('3 s**2|,s**2') }.to raise_error(ArgumentError, /Unit not recognized/)
  end

  specify 'no multiple spaces' do
    expect { RubyUnits::Unit.new('3 s**2 4s s**2') }.to raise_error(ArgumentError, /Unit not recognized/)
  end

  specify 'no exponentiation of numbers' do
    expect { RubyUnits::Unit.new('3 s 5^6') }.to raise_error(ArgumentError, /Unit not recognized/)
  end

  specify "no strings that don't specify a valid unit" do
    expect { RubyUnits::Unit.new('random string') }.to raise_error(ArgumentError, "'random string' Unit not recognized")
  end

  specify 'no unhandled classes' do
    expect { RubyUnits::Unit.new(STDIN) }.to raise_error(ArgumentError, 'Invalid Unit Format')
  end

  specify 'no undefined units' do
    expect { RubyUnits::Unit.new('1 mFoo') }.to raise_error(ArgumentError, "'1 mFoo' Unit not recognized")
    expect { RubyUnits::Unit.new('1 second/mFoo') }.to raise_error(ArgumentError, "'1 second/mFoo' Unit not recognized")
  end

  specify 'no units with powers greater than 19' do
    expect { RubyUnits::Unit.new('1 m^20') }.to raise_error(ArgumentError, 'Power out of range (-20 < net power of a unit < 20)')
  end

  specify 'no units with powers less than 19' do
    expect { RubyUnits::Unit.new('1 m^-20') }.to raise_error(ArgumentError, 'Power out of range (-20 < net power of a unit < 20)')
  end

  specify 'no temperatures less than absolute zero' do
    expect { RubyUnits::Unit.new('-100 tempK') }.to raise_error(ArgumentError, 'Temperatures must not be less than absolute zero')
    expect { RubyUnits::Unit.new('-100 tempR') }.to raise_error(ArgumentError, 'Temperatures must not be less than absolute zero')
    expect { RubyUnits::Unit.new('-500/9 tempR') }.to raise_error(ArgumentError, 'Temperatures must not be less than absolute zero')
  end

  specify 'no nil scalar' do
    expect { RubyUnits::Unit.new(nil, 'feet') }.to raise_error(ArgumentError, 'Invalid Unit Format')
    expect { RubyUnits::Unit.new(nil, 'feet', 'min') }.to raise_error(ArgumentError, 'Invalid Unit Format')
  end

  specify 'no double prefixes' do
    expect { Unit.new('1 mmm') }.to raise_error(ArgumentError, /Unit not recognized/)
  end
end

describe Unit do
  it 'is a subclass of Numeric' do
    expect(described_class).to be < Numeric
  end

  it 'is Comparable' do
    expect(described_class).to be < Comparable
  end

  describe '#defined?' do
    it 'should return true when asked about a defined unit' do
      expect(Unit.defined?('meter')).to be_truthy
    end

    it 'should return true when asked about an alias for a unit' do
      expect(Unit.defined?('m')).to be_truthy
    end

    it 'should return false when asked about a unit that is not defined' do
      expect(Unit.defined?('doohickey')).to be_falsey
    end
  end

  describe '#to_yaml' do
    subject { RubyUnits::Unit.new('1 mm') }

    describe '#to_yaml' do
      subject { super().to_yaml }
      it { is_expected.to match(%r{--- !ruby\/object:RubyUnits::Unit}) }
    end
  end

  describe '#definition' do
    context 'The requested unit is defined' do
      before(:each) do
        @definition = Unit.definition('mph')
      end

      it 'should return a Unit::Definition' do
        expect(@definition).to be_instance_of(Unit::Definition)
      end

      specify { expect(@definition.name).to eq('<mph>') }
      specify { expect(@definition.aliases).to eq(%w[mph]) }
      specify { expect(@definition.numerator).to eq(['<meter>']) }
      specify { expect(@definition.denominator).to eq(['<second>']) }
      specify { expect(@definition.kind).to eq(:speed) }
      specify { expect(@definition.scalar).to be === 0.44704 }
    end

    context 'The requested unit is not defined' do
      it 'should return nil' do
        expect(Unit.definition('doohickey')).to be_nil
      end
    end
  end

  describe '#define' do
    describe 'a new unit' do
      before(:each) do
        # do this because the unit is not defined at the time this file is parsed, so it fails
        @jiffy = Unit.define('jiffy') do |jiffy|
          jiffy.scalar = Rational(1, 100)
          jiffy.aliases = %w[jif]
          jiffy.numerator = ['<second>']
          jiffy.kind = :time
        end
      end

      after(:each) do
        Unit.undefine!('jiffy')
      end

      describe "RubyUnits::Unit.new('1e6 jiffy')" do
        subject { RubyUnits::Unit.new('1e6 jiffy') }

        it { is_expected.to be_a Numeric }
        it { is_expected.to be_an_instance_of Unit }

        describe '#scalar' do
          subject { super().scalar }
          it { is_expected.to eq(1e6) }
        end

        describe '#scalar' do
          subject { super().scalar }
          it { is_expected.to be_an Integer }
        end

        describe '#units' do
          subject { super().units }
          it { is_expected.to eq('jif') }
        end

        describe '#kind' do
          subject { super().kind }
          it { is_expected.to eq(:time) }
        end
        it { is_expected.not_to be_temperature }
        it { is_expected.not_to be_degree }
        it { is_expected.not_to be_base }
        it { is_expected.not_to be_unitless }
        it { is_expected.not_to be_zero }

        describe '#base' do
          subject { super().base }
          it { is_expected.to eq(RubyUnits::Unit.new('10000 s')) }
        end
      end

      it 'should register the new unit' do
        expect(Unit.defined?('jiffy')).to be_truthy
      end
    end

    describe 'an existing unit again' do
      before(:each) do
        @cups = Unit.definition('cup')
        @original_display_name = @cups.display_name
        @cups.display_name = 'cupz'
        Unit.define(@cups)
      end

      after(:each) do
        Unit.redefine!('cup') do |cup|
          cup.display_name = @original_display_name
        end
      end

      describe "RubyUnits::Unit.new('1 cup')" do
        # do this because the unit is going to be redefined
        subject { RubyUnits::Unit.new('1 cup') }

        it { is_expected.to be_a Numeric }
        it { is_expected.to be_an_instance_of Unit }

        describe '#scalar' do
          subject { super().scalar }
          it { is_expected.to eq(1) }
        end

        describe '#scalar' do
          subject { super().scalar }
          it { is_expected.to be_an Integer }
        end

        describe '#units' do
          subject { super().units }
          it { is_expected.to eq('cupz') }
        end

        describe '#kind' do
          subject { super().kind }
          it { is_expected.to eq(:volume) }
        end
        it { is_expected.not_to be_temperature }
        it { is_expected.not_to be_degree }
        it { is_expected.not_to be_base }
        it { is_expected.not_to be_unitless }
        it { is_expected.not_to be_zero }
      end
    end
  end

  describe '#redefine!' do
    before(:each) do
      @jiffy = Unit.define('jiffy') do |jiffy|
        jiffy.scalar = (1 / 100)
        jiffy.aliases = %w[jif]
        jiffy.numerator = ['<second>']
        jiffy.kind = :time
      end

      Unit.redefine!('jiffy') do |jiffy|
        jiffy.scalar = (1 / 1000)
      end
    end

    after(:each) do
      Unit.undefine!('jiffy')
    end

    specify { expect(RubyUnits::Unit.new('1 jiffy').to_base.scalar).to eq(1 / 1000) }
  end

  describe '#undefine!' do
    before(:each) do
      @jiffy = Unit.define('jiffy') do |jiffy|
        jiffy.scalar = (1 / 100)
        jiffy.aliases = %w[jif]
        jiffy.numerator = ['<second>']
        jiffy.kind = :time
      end
      Unit.undefine!('jiffy')
    end

    specify 'the unit should be undefined' do
      expect(Unit.defined?('jiffy')).to be_falsey
    end

    specify 'attempting to use an undefined unit fails' do
      expect { RubyUnits::Unit.new('1 jiffy') }.to raise_exception(ArgumentError)
    end

    it 'should return true when undefining an unknown unit' do
      expect(Unit.defined?('unknown')).to be_falsey
      expect(Unit.undefine!('unknown')).to be_truthy
    end
  end

  describe '#clone' do
    subject { RubyUnits::Unit.new('1 mm') }

    describe '#clone' do
      subject { super().clone }
      it { is_expected.to be === subject }
    end
  end
end

describe 'Unit Comparisons' do
  context "Unit should detect if two units are 'compatible' (i.e., can be converted into each other)" do
    specify { expect(RubyUnits::Unit.new('1 ft') =~ RubyUnits::Unit.new('1 m')).to be true }
    specify { expect(RubyUnits::Unit.new('1 ft') =~ 'm').to be true }
    specify { expect(RubyUnits::Unit.new('1 ft')).to be_compatible_with RubyUnits::Unit.new('1 m') }
    specify { expect(RubyUnits::Unit.new('1 ft')).to be_compatible_with 'm' }
    specify { expect(RubyUnits::Unit.new('1 m')).to be_compatible_with RubyUnits::Unit.new('1 kg*m/kg') }
    specify { expect(RubyUnits::Unit.new('1 ft') =~ RubyUnits::Unit.new('1 kg')).to be false }
    specify { expect(RubyUnits::Unit.new('1 ft')).not_to be_compatible_with RubyUnits::Unit.new('1 kg') }
    specify { expect(RubyUnits::Unit.new('1 ft')).not_to be_compatible_with nil }
  end

  context 'Equality' do
    context 'with uncoercable objects' do
      specify { expect(RubyUnits::Unit.new('1 mm')).not_to eq(nil) }
    end

    context 'units of same kind' do
      specify { expect(RubyUnits::Unit.new('1000 m')).to eq(RubyUnits::Unit.new('1 km')) }
      specify { expect(RubyUnits::Unit.new('100 m')).not_to eq(RubyUnits::Unit.new('1 km')) }
      specify { expect(RubyUnits::Unit.new('1 m')).to eq(RubyUnits::Unit.new('100 cm')) }
    end

    context 'units of incompatible types' do
      specify { expect(RubyUnits::Unit.new('1 m')).not_to eq(RubyUnits::Unit.new('1 kg')) }
    end

    context 'units with a zero scalar are equal' do
      specify { expect(RubyUnits::Unit.new('0 m')).to eq(RubyUnits::Unit.new('0 s')) }
      specify { expect(RubyUnits::Unit.new('0 m')).to eq(RubyUnits::Unit.new('0 kg')) }

      context 'except for temperature units' do
        specify { expect(RubyUnits::Unit.new('0 tempK')).to eq(RubyUnits::Unit.new('0 m')) }
        specify { expect(RubyUnits::Unit.new('0 tempR')).to eq(RubyUnits::Unit.new('0 m')) }
        specify { expect(RubyUnits::Unit.new('0 tempC')).not_to eq(RubyUnits::Unit.new('0 m')) }
        specify { expect(RubyUnits::Unit.new('0 tempF')).not_to eq(RubyUnits::Unit.new('0 m')) }
      end
    end
  end

  context 'Equivalence' do
    context 'units and scalars are the exactly the same' do
      specify { expect(RubyUnits::Unit.new('1 m')).to be === RubyUnits::Unit.new('1 m') }
      specify { expect(RubyUnits::Unit.new('1 m')).to be_same RubyUnits::Unit.new('1 m') }
      specify { expect(RubyUnits::Unit.new('1 m')).to be_same_as RubyUnits::Unit.new('1 m') }
    end

    context 'units are compatible but not identical' do
      specify { expect(RubyUnits::Unit.new('1000 m')).not_to be === RubyUnits::Unit.new('1 km') }
      specify { expect(RubyUnits::Unit.new('1000 m')).not_to be_same RubyUnits::Unit.new('1 km') }
      specify { expect(RubyUnits::Unit.new('1000 m')).not_to be_same_as RubyUnits::Unit.new('1 km') }
    end

    context 'units are not compatible' do
      specify { expect(RubyUnits::Unit.new('1000 m')).not_to be === RubyUnits::Unit.new('1 hour') }
      specify { expect(RubyUnits::Unit.new('1000 m')).not_to be_same RubyUnits::Unit.new('1 hour') }
      specify { expect(RubyUnits::Unit.new('1000 m')).not_to be_same_as RubyUnits::Unit.new('1 hour') }
    end

    context 'scalars are different' do
      specify { expect(RubyUnits::Unit.new('1 m')).not_to be === RubyUnits::Unit.new('2 m') }
      specify { expect(RubyUnits::Unit.new('1 m')).not_to be_same RubyUnits::Unit.new('2 m') }
      specify { expect(RubyUnits::Unit.new('1 m')).not_to be_same_as RubyUnits::Unit.new('2 m') }
    end

    specify { expect(RubyUnits::Unit.new('1 m')).not_to be_nil }
  end

  context 'Comparisons' do
    context 'compatible units can be compared' do
      specify { expect(RubyUnits::Unit.new('1 m')).to be < RubyUnits::Unit.new('2 m') }
      specify { expect(RubyUnits::Unit.new('2 m')).to be > RubyUnits::Unit.new('1 m') }
      specify { expect(RubyUnits::Unit.new('1 m')).to be < RubyUnits::Unit.new('1 mi') }
      specify { expect(RubyUnits::Unit.new('2 m')).to be > RubyUnits::Unit.new('1 ft') }
      specify { expect(RubyUnits::Unit.new('70 tempF')).to be > RubyUnits::Unit.new('10 degC') }
      specify { expect(RubyUnits::Unit.new('1 m')).to be > 0 }
      specify { expect { RubyUnits::Unit.new('1 m') > nil }.to raise_error(ArgumentError, /comparison of RubyUnits::Unit with (nil failed|NilClass)/) }
    end

    context 'incompatible units cannot be compared' do
      specify { expect { RubyUnits::Unit.new('1 m') < RubyUnits::Unit.new('1 liter') }.to raise_error(ArgumentError, "Incompatible Units ('m' not compatible with 'l')") }
      specify { expect { RubyUnits::Unit.new('1 kg') > RubyUnits::Unit.new('60 mph') }.to raise_error(ArgumentError, "Incompatible Units ('kg' not compatible with 'mph')") }
    end

    context 'with coercions should be valid' do
      specify { expect(RubyUnits::Unit.new('1GB') > '500MB').to eq(true) }
      specify { expect(RubyUnits::Unit.new('0.5GB') < '900MB').to eq(true) }
    end
  end
end

describe 'Unit Conversions' do
  context 'between compatible units' do
    specify { expect(RubyUnits::Unit.new('1 s').convert_to('ns')).to eq(RubyUnits::Unit.new('1e9 ns')) }
    specify { expect(RubyUnits::Unit.new('1 s').convert_to('ns')).to eq(RubyUnits::Unit.new('1e9 ns')) }
    specify { expect(RubyUnits::Unit.new('1 s') >> 'ns').to eq(RubyUnits::Unit.new('1e9 ns')) }

    specify { expect(RubyUnits::Unit.new('1 m').convert_to(RubyUnits::Unit.new('ft'))).to be_within(RubyUnits::Unit.new('0.001 ft')).of(RubyUnits::Unit.new('3.28084 ft')) }
  end

  context 'between incompatible units' do
    specify { expect { RubyUnits::Unit.new('1 s').convert_to('m') }.to raise_error(ArgumentError, "Incompatible Units ('1 s' not compatible with 'm')") }
  end

  context 'given bad input' do
    specify { expect { RubyUnits::Unit.new('1 m').convert_to('random string') }.to raise_error(ArgumentError, "'random string' Unit not recognized") }
    specify { expect { RubyUnits::Unit.new('1 m').convert_to(STDOUT) }.to raise_error(ArgumentError, 'Unknown target units') }
  end

  context 'between temperature scales' do
    # note that 'temp' units are for temperature readings on a scale, while 'deg' units are used to represent
    # differences between temperatures, offsets, or other differential temperatures.

    specify { expect(RubyUnits::Unit.new('100 tempC')).to be_within(RubyUnits::Unit.new('0.001 degK')).of(RubyUnits::Unit.new('373.15 tempK')) }
    specify { expect(RubyUnits::Unit.new('0 tempC')).to be_within(RubyUnits::Unit.new('0.001 degK')).of(RubyUnits::Unit.new('273.15 tempK')) }
    specify { expect(RubyUnits::Unit.new('37 tempC')).to be_within(RubyUnits::Unit.new('0.01 degK')).of(RubyUnits::Unit.new('310.15 tempK')) }
    specify { expect(RubyUnits::Unit.new('-273.15 tempC')).to eq(RubyUnits::Unit.new('0 tempK')) }

    specify { expect(RubyUnits::Unit.new('212 tempF')).to be_within(RubyUnits::Unit.new('0.001 degK')).of(RubyUnits::Unit.new('373.15 tempK')) }
    specify { expect(RubyUnits::Unit.new('32 tempF')).to be_within(RubyUnits::Unit.new('0.001 degK')).of(RubyUnits::Unit.new('273.15 tempK')) }
    specify { expect(RubyUnits::Unit.new('98.6 tempF')).to be_within(RubyUnits::Unit.new('0.01 degK')).of(RubyUnits::Unit.new('310.15 tempK')) }
    specify { expect(RubyUnits::Unit.new('-459.67 tempF')).to eq(RubyUnits::Unit.new('0 tempK')) }

    specify { expect(RubyUnits::Unit.new('671.67 tempR')).to be_within(RubyUnits::Unit.new('0.001 degK')).of(RubyUnits::Unit.new('373.15 tempK')) }
    specify { expect(RubyUnits::Unit.new('491.67 tempR')).to be_within(RubyUnits::Unit.new('0.001 degK')).of(RubyUnits::Unit.new('273.15 tempK')) }
    specify { expect(RubyUnits::Unit.new('558.27 tempR')).to be_within(RubyUnits::Unit.new('0.01 degK')).of(RubyUnits::Unit.new('310.15 tempK')) }
    specify { expect(RubyUnits::Unit.new('0 tempR')).to eq(RubyUnits::Unit.new('0 tempK')) }

    specify { expect(RubyUnits::Unit.new('100 tempK').convert_to('tempC')).to be_within(RubyUnits::Unit.new('0.01 degC')).of(RubyUnits::Unit.new('-173.15 tempC')) }
    specify { expect(RubyUnits::Unit.new('100 tempK').convert_to('tempF')).to be_within(RubyUnits::Unit.new('0.01 degF')).of(RubyUnits::Unit.new('-279.67 tempF')) }
    specify { expect(RubyUnits::Unit.new('100 tempK').convert_to('tempR')).to be_within(RubyUnits::Unit.new('0.01 degR')).of(RubyUnits::Unit.new('180 tempR')) }

    specify { expect(RubyUnits::Unit.new('1 degC')).to eq(RubyUnits::Unit.new('1 degK')) }
    specify { expect(RubyUnits::Unit.new('1 degF')).to eq(RubyUnits::Unit.new('1 degR')) }
    specify { expect(RubyUnits::Unit.new('1 degC')).to eq(RubyUnits::Unit.new('1.8 degR')) }
    specify { expect(RubyUnits::Unit.new('1 degF')).to be_within(RubyUnits::Unit.new('0.001 degK')).of(RubyUnits::Unit.new('0.5555 degK')) }
  end

  context 'reported bugs' do
    specify { expect(RubyUnits::Unit.new('189 Mtonne') * RubyUnits::Unit.new('1189 g/tonne')).to eq(RubyUnits::Unit.new('224721 tonne')) }
    specify { expect((RubyUnits::Unit.new('189 Mtonne') * RubyUnits::Unit.new('1189 g/tonne')).convert_to('tonne')).to eq(RubyUnits::Unit.new('224721 tonne')) }
  end

  describe 'Foot-inch conversions' do
    [
      ['76 in', %(6'4")],
      ['77 in', %(6'5")],
      ['78 in', %(6'6")],
      ['79 in', %(6'7")],
      ['80 in', %(6'8")],
      ['87 in', %(7'3")],
      ['88 in', %(7'4")],
      ['89 in', %(7'5")]
    ].each do |inches, feet|
      specify { expect(RubyUnits::Unit.new(inches).convert_to('ft')).to eq(RubyUnits::Unit.new(feet)) }
      specify { expect(RubyUnits::Unit.new(inches).to_s(:ft)).to eq(feet) }
    end
  end

  describe 'pound-ounce conversions' do
    [
      ['76 oz', '4 lbs, 12 oz'],
      ['77 oz', '4 lbs, 13 oz'],
      ['78 oz', '4 lbs, 14 oz'],
      ['79 oz', '4 lbs, 15 oz'],
      ['80 oz', '5 lbs, 0 oz'],
      ['87 oz', '5 lbs, 7 oz'],
      ['88 oz', '5 lbs, 8 oz'],
      ['89 oz', '5 lbs, 9 oz']
    ].each do |ounces, pounds|
      specify { expect(RubyUnits::Unit.new(ounces).convert_to('lbs')).to eq(RubyUnits::Unit.new(pounds)) }
      specify { expect(RubyUnits::Unit.new(ounces).to_s(:lbs)).to eq(pounds) }
    end
  end

  describe 'stone-pound conversions' do
    [
      ['14 stone 4', '200 lbs'],
      ['14 st 4', '200 lbs'],
      ['14 stone, 4 pounds', '200 lbs'],
      ['14 st, 4 lbs', '200 lbs']
    ].each do |stone, pounds|
      specify { expect(RubyUnits::Unit.new(stone).convert_to('lbs')).to eq(RubyUnits::Unit.new(pounds)) }
    end
    specify { expect(RubyUnits::Unit.new('200 lbs').to_s(:stone)).to eq '14 stone, 4 lb' }
  end
end

describe 'Unit Math' do
  context 'operators:' do
    context 'addition (+)' do
      context 'between compatible units' do
        specify { expect(RubyUnits::Unit.new('0 m') + RubyUnits::Unit.new('10 m')).to eq(RubyUnits::Unit.new('10 m')) }
        specify { expect(RubyUnits::Unit.new('5 kg') + RubyUnits::Unit.new('10 kg')).to eq(RubyUnits::Unit.new('15 kg')) }
      end

      context 'between a zero unit and another unit' do
        specify { expect(RubyUnits::Unit.new('0 kg') + RubyUnits::Unit.new('10 m')).to eq(RubyUnits::Unit.new('10 m')) }
        specify { expect(RubyUnits::Unit.new('0 m') + RubyUnits::Unit.new('10 kg')).to eq(RubyUnits::Unit.new('10 kg')) }
      end

      context 'between incompatible units' do
        specify { expect { RubyUnits::Unit.new('10 kg') + RubyUnits::Unit.new('10 m') }.to raise_error(ArgumentError) }
        specify { expect { RubyUnits::Unit.new('10 m') + RubyUnits::Unit.new('10 kg') }.to raise_error(ArgumentError) }
        specify { expect { RubyUnits::Unit.new('10 m') + nil }.to raise_error(ArgumentError) }
      end

      context 'a number from a unit' do
        specify { expect { RubyUnits::Unit.new('10 kg') + 1 }.to raise_error(ArgumentError) }
        specify { expect { 10 + RubyUnits::Unit.new('10 kg') }.to raise_error(ArgumentError) }
      end

      context 'between a unit and coerceable types' do
        specify { expect(RubyUnits::Unit.new('10 kg') + %w[1 kg]).to eq(RubyUnits::Unit.new('11 kg')) }
        specify { expect(RubyUnits::Unit.new('10 kg') + '1 kg').to eq(RubyUnits::Unit.new('11 kg')) }
      end

      context 'between two temperatures' do
        specify { expect { (RubyUnits::Unit.new('100 tempK') + RubyUnits::Unit.new('100 tempK')) }.to raise_error(ArgumentError, 'Cannot add two temperatures') }
      end

      context 'between a temperature and a degree' do
        specify { expect(RubyUnits::Unit.new('100 tempK') + RubyUnits::Unit.new('100 degK')).to eq(RubyUnits::Unit.new('200 tempK')) }
      end

      context 'between a degree and a temperature' do
        specify { expect(RubyUnits::Unit.new('100 degK') + RubyUnits::Unit.new('100 tempK')).to eq(RubyUnits::Unit.new('200 tempK')) }
      end

      context 'between two unitless units' do
        specify { expect(RubyUnits::Unit.new('1') + RubyUnits::Unit.new('2')).to eq 3 }
      end
    end

    context 'subtracting (-)' do
      context 'compatible units' do
        specify { expect(RubyUnits::Unit.new('0 m') - RubyUnits::Unit.new('10 m')).to eq(RubyUnits::Unit.new('-10 m')) }
        specify { expect(RubyUnits::Unit.new('5 kg') - RubyUnits::Unit.new('10 kg')).to eq(RubyUnits::Unit.new('-5 kg')) }
      end

      context 'a unit from a zero unit' do
        specify { expect(RubyUnits::Unit.new('0 kg') - RubyUnits::Unit.new('10 m')).to eq(RubyUnits::Unit.new('-10 m')) }
        specify { expect(RubyUnits::Unit.new('0 m') - RubyUnits::Unit.new('10 kg')).to eq(RubyUnits::Unit.new('-10 kg')) }
      end

      context 'incompatible units' do
        specify { expect { RubyUnits::Unit.new('10 kg') - RubyUnits::Unit.new('10 m') }.to raise_error(ArgumentError) }
        specify { expect { RubyUnits::Unit.new('10 m') - RubyUnits::Unit.new('10 kg') }.to raise_error(ArgumentError) }
        specify { expect { RubyUnits::Unit.new('10 m') - nil }.to raise_error(ArgumentError) }
      end

      context 'between a unit and coerceable types' do
        specify { expect(RubyUnits::Unit.new('10 kg') - %w[1 kg]).to eq(RubyUnits::Unit.new('9 kg')) }
        specify { expect(RubyUnits::Unit.new('10 kg') - '1 kg').to eq(RubyUnits::Unit.new('9 kg')) }
      end

      context 'a number from a unit' do
        specify { expect { RubyUnits::Unit.new('10 kg') - 1 }.to raise_error(ArgumentError) }
        specify { expect { 10 - RubyUnits::Unit.new('10 kg') }.to raise_error(ArgumentError) }
      end

      context 'between two temperatures' do
        specify { expect(RubyUnits::Unit.new('100 tempK') - RubyUnits::Unit.new('100 tempK')).to eq(RubyUnits::Unit.new('0 degK')) }
      end

      context 'between a temperature and a degree' do
        specify { expect(RubyUnits::Unit.new('100 tempK') - RubyUnits::Unit.new('100 degK')).to eq(RubyUnits::Unit.new('0 tempK')) }
      end

      context 'between a degree and a temperature' do
        specify { expect { (RubyUnits::Unit.new('100 degK') - RubyUnits::Unit.new('100 tempK')) }.to raise_error(ArgumentError, 'Cannot subtract a temperature from a differential degree unit') }
      end

      context 'a unitless unit from another unitless unit' do
        specify { expect(RubyUnits::Unit.new('1') - RubyUnits::Unit.new('2')).to eq -1 }
      end
    end

    context 'multiplying (*)' do
      context 'between compatible units' do
        specify { expect(RubyUnits::Unit.new('0 m') * RubyUnits::Unit.new('10 m')).to eq(RubyUnits::Unit.new('0 m^2')) }
        specify { expect(RubyUnits::Unit.new('5 kg') * RubyUnits::Unit.new('10 kg')).to eq(RubyUnits::Unit.new('50 kg^2')) }
      end

      context 'between incompatible units' do
        specify { expect(RubyUnits::Unit.new('0 m') * RubyUnits::Unit.new('10 kg')).to eq(RubyUnits::Unit.new('0 kg*m')) }
        specify { expect(RubyUnits::Unit.new('5 m') * RubyUnits::Unit.new('10 kg')).to eq(RubyUnits::Unit.new('50 kg*m')) }
        specify { expect { RubyUnits::Unit.new('10 m') * nil }.to raise_error(ArgumentError) }
      end

      context 'between a unit and coerceable types' do
        specify { expect(RubyUnits::Unit.new('10 kg') * %w[1 kg]).to eq(RubyUnits::Unit.new('10 kg^2')) }
        specify { expect(RubyUnits::Unit.new('10 kg') * '1 kg').to eq(RubyUnits::Unit.new('10 kg^2')) }
      end

      context 'by a temperature' do
        specify { expect { RubyUnits::Unit.new('5 kg') * RubyUnits::Unit.new('100 tempF') }.to raise_exception(ArgumentError) }
      end

      context 'by a number' do
        specify { expect(10 * RubyUnits::Unit.new('5 kg')).to eq(RubyUnits::Unit.new('50 kg')) }
      end
    end

    context 'dividing (/)' do
      context 'compatible units' do
        specify { expect(RubyUnits::Unit.new('0 m') / RubyUnits::Unit.new('10 m')).to eq(RubyUnits::Unit.new(0)) }
        specify { expect(RubyUnits::Unit.new('5 kg') / RubyUnits::Unit.new('10 kg')).to eq(Rational(1, 2)) }
        specify { expect(RubyUnits::Unit.new('5 kg') / RubyUnits::Unit.new('5 kg')).to eq(1) }
      end

      context 'incompatible units' do
        specify { expect(RubyUnits::Unit.new('0 m') / RubyUnits::Unit.new('10 kg')).to eq(RubyUnits::Unit.new('0 m/kg')) }
        specify { expect(RubyUnits::Unit.new('5 m') / RubyUnits::Unit.new('10 kg')).to eq(RubyUnits::Unit.new('1/2 m/kg')) }
        specify { expect { RubyUnits::Unit.new('10 m') / nil }.to raise_error(ArgumentError) }
      end

      context 'between a unit and coerceable types' do
        specify { expect(RubyUnits::Unit.new('10 kg^2') / %w[1 kg]).to eq(RubyUnits::Unit.new('10 kg')) }
        specify { expect(RubyUnits::Unit.new('10 kg^2') / '1 kg').to eq(RubyUnits::Unit.new('10 kg')) }
      end

      context 'by a temperature' do
        specify { expect { RubyUnits::Unit.new('5 kg') / RubyUnits::Unit.new('100 tempF') }.to raise_exception(ArgumentError) }
      end

      context 'a number by a unit' do
        specify { expect(10 / RubyUnits::Unit.new('5 kg')).to eq(RubyUnits::Unit.new('2 1/kg')) }
      end

      context 'a unit by a number' do
        specify { expect(RubyUnits::Unit.new('5 kg') / 2).to eq(RubyUnits::Unit.new('2.5 kg')) }
      end

      context 'by zero' do
        specify { expect { RubyUnits::Unit.new('10 m') / 0 }.to raise_error(ZeroDivisionError) }
        specify { expect { RubyUnits::Unit.new('10 m') / RubyUnits::Unit.new('0 m') }.to raise_error(ZeroDivisionError) }
        specify { expect { RubyUnits::Unit.new('10 m') / RubyUnits::Unit.new('0 kg') }.to raise_error(ZeroDivisionError) }
      end
    end

    context 'exponentiating (**)' do
      specify 'a temperature raises an execption' do
        expect { RubyUnits::Unit.new('100 tempK')**2 }.to raise_error(ArgumentError, 'Cannot raise a temperature to a power')
      end

      context RubyUnits::Unit.new('0 m') do
        it { expect(subject**1).to eq(subject) }
        it { expect(subject**2).to eq(subject) }
      end

      context RubyUnits::Unit.new('1 m') do
        it { expect(subject**0).to eq(1) }
        it { expect(subject**1).to eq(subject) }
        it { expect(subject**-1).to eq(1 / subject) }
        it { expect(subject**2).to eq(RubyUnits::Unit.new('1 m^2')) }
        it { expect(subject**-2).to eq(RubyUnits::Unit.new('1 1/m^2')) }
        specify { expect { subject**Rational(1, 2) }.to raise_error(ArgumentError, 'Illegal root') }
        # because 1 m^(1/2) doesn't make any sense
        specify { expect { subject**Complex(1, 1) }.to raise_error(ArgumentError, 'exponentiation of complex numbers is not supported.') }
        specify { expect { subject**RubyUnits::Unit.new('1 m') }.to raise_error(ArgumentError, 'Invalid Exponent') }
      end

      context RubyUnits::Unit.new('1 m^2') do
        it { expect(subject**Rational(1, 2)).to eq(RubyUnits::Unit.new('1 m')) }
        it { expect(subject**0.5).to eq(RubyUnits::Unit.new('1 m')) }

        specify { expect { subject**0.12345 }.to raise_error(ArgumentError, 'Not a n-th root (1..9), use 1/n') }
        specify { expect { subject**'abcdefg' }.to raise_error(ArgumentError, 'Invalid Exponent') }
      end
    end

    context 'modulo (%)' do
      context 'compatible units' do
        specify { expect(RubyUnits::Unit.new('2 m') % RubyUnits::Unit.new('1 m')).to eq(0) }
        specify { expect(RubyUnits::Unit.new('5 m') % RubyUnits::Unit.new('2 m')).to eq(1) }
      end

      specify 'incompatible units raises an exception' do
        expect { RubyUnits::Unit.new('1 m') % RubyUnits::Unit.new('1 kg') }.to raise_error(ArgumentError, "Incompatible Units ('1 m' not compatible with '1 kg')")
      end
    end

    context 'unary negation (-)' do
      specify { expect(-RubyUnits::Unit.new('1 mm')).to eq(RubyUnits::Unit.new('-1 mm')) }
    end

    context 'unary plus (+)' do
      specify { expect(+RubyUnits::Unit.new('1 mm')).to eq(RubyUnits::Unit.new('1 mm')) }
    end
  end

  context '#power' do
    subject { RubyUnits::Unit.new('1 m') }
    it 'raises an exception when passed a Float argument' do
      expect { subject.power(1.5) }.to raise_error(ArgumentError, 'Exponent must an Integer')
    end
    it 'raises an exception when passed a Rational argument' do
      expect { subject.power(Rational(1, 2)) }.to raise_error(ArgumentError, 'Exponent must an Integer')
    end
    it 'raises an exception when passed a Complex argument' do
      expect { subject.power(Complex(1, 2)) }.to raise_error(ArgumentError, 'Exponent must an Integer')
    end
    it 'raises an exception when called on a temperature unit' do
      expect { RubyUnits::Unit.new('100 tempC').power(2) }.to raise_error(ArgumentError, 'Cannot raise a temperature to a power')
    end

    specify { expect(subject.power(-1)).to eq(RubyUnits::Unit.new('1 1/m')) }
    specify { expect(subject.power(0)).to eq(1) }
    specify { expect(subject.power(1)).to eq(subject) }
    specify { expect(subject.power(2)).to eq(RubyUnits::Unit.new('1 m^2')) }
  end

  context '#root' do
    subject { RubyUnits::Unit.new('1 m') }
    it 'raises an exception when passed a Float argument' do
      expect { subject.root(1.5) }.to raise_error(ArgumentError, 'Exponent must an Integer')
    end
    it 'raises an exception when passed a Rational argument' do
      expect { subject.root(Rational(1, 2)) }.to raise_error(ArgumentError, 'Exponent must an Integer')
    end
    it 'raises an exception when passed a Complex argument' do
      expect { subject.root(Complex(1, 2)) }.to raise_error(ArgumentError, 'Exponent must an Integer')
    end
    it 'raises an exception when called on a temperature unit' do
      expect { RubyUnits::Unit.new('100 tempC').root(2) }.to raise_error(ArgumentError, 'Cannot take the root of a temperature')
    end

    specify { expect(RubyUnits::Unit.new('1 m^2').root(-2)).to eq(RubyUnits::Unit.new('1 1/m')) }
    specify { expect(subject.root(-1)).to eq(RubyUnits::Unit.new('1 1/m')) }
    specify { expect { subject.root(0) }.to raise_error(ArgumentError, '0th root undefined') }
    specify { expect(subject.root(1)).to eq(subject) }
    specify { expect(RubyUnits::Unit.new('1 m^2').root(2)).to eq(RubyUnits::Unit.new('1 m')) }
  end

  context '#inverse' do
    specify { expect(RubyUnits::Unit.new('1 m').inverse).to eq(RubyUnits::Unit.new('1 1/m')) }
    specify { expect { RubyUnits::Unit.new('100 tempK').inverse }.to raise_error(ArgumentError, 'Cannot divide with temperatures') }
  end

  context 'convert to scalars' do
    specify { expect(RubyUnits::Unit.new('10').to_i).to be_kind_of(Integer) }
    specify { expect { RubyUnits::Unit.new('10 m').to_i }.to raise_error(RuntimeError, "Cannot convert '10 m' to Integer unless unitless.  Use Unit#scalar") }

    specify { expect(RubyUnits::Unit.new('10.0').to_f).to be_kind_of(Float) }
    specify { expect { RubyUnits::Unit.new('10.0 m').to_f }.to raise_error(RuntimeError, "Cannot convert '10 m' to Float unless unitless.  Use Unit#scalar") }

    specify { expect(RubyUnits::Unit.new('1+1i').to_c).to be_kind_of(Complex) }
    specify { expect { RubyUnits::Unit.new('1+1i m').to_c }.to raise_error(RuntimeError, "Cannot convert '1.0+1.0i m' to Complex unless unitless.  Use Unit#scalar") }

    specify { expect(RubyUnits::Unit.new('3/7').to_r).to be_kind_of(Rational) }
    specify { expect { RubyUnits::Unit.new('3/7 m').to_r }.to raise_error(RuntimeError, "Cannot convert '3/7 m' to Rational unless unitless.  Use Unit#scalar") }
  end

  context 'absolute value (#abs)' do
    context 'of a unitless unit' do
      specify 'returns the absolute value of the scalar' do
        expect(RubyUnits::Unit.new('-10').abs).to eq(10)
      end
    end

    context 'of a unit' do
      specify 'returns a unit with the absolute value of the scalar' do
        expect(RubyUnits::Unit.new('-10 m').abs).to eq(RubyUnits::Unit.new('10 m'))
      end
    end
  end

  context '#ceil' do
    context 'of a unitless unit' do
      specify 'returns the ceil of the scalar' do
        expect(RubyUnits::Unit.new('10.1').ceil).to eq(11)
      end
    end

    context 'of a unit' do
      specify 'returns a unit with the ceil of the scalar' do
        expect(RubyUnits::Unit.new('10.1 m').ceil).to eq(RubyUnits::Unit.new('11 m'))
      end
    end
  end

  context '#floor' do
    context 'of a unitless unit' do
      specify 'returns the floor of the scalar' do
        expect(RubyUnits::Unit.new('10.1').floor).to eq(10)
      end
    end

    context 'of a unit' do
      specify 'returns a unit with the floor of the scalar' do
        expect(RubyUnits::Unit.new('10.1 m').floor).to eq(RubyUnits::Unit.new('10 m'))
      end
    end
  end

  context '#round' do
    context 'of a unitless unit' do
      specify 'returns the round of the scalar' do
        expect(RubyUnits::Unit.new('10.5').round).to eq(11)
      end
    end

    context 'of a unit' do
      specify 'returns a unit with the round of the scalar' do
        expect(RubyUnits::Unit.new('10.5 m').round).to eq(RubyUnits::Unit.new('11 m'))
      end
    end
  end

  context '#truncate' do
    context 'of a unitless unit' do
      specify 'returns the truncate of the scalar' do
        expect(RubyUnits::Unit.new('10.5').truncate).to eq(10)
      end
    end

    context 'of a unit' do
      specify 'returns a unit with the truncate of the scalar' do
        expect(RubyUnits::Unit.new('10.5 m').truncate).to eq(RubyUnits::Unit.new('10 m'))
      end
    end

    context 'of a complex unit' do
      specify 'returns a unit with the truncate of the scalar' do
        expect(RubyUnits::Unit.new('10.5 kg*m/s^3').truncate).to eq(RubyUnits::Unit.new('10 kg*m/s^3'))
      end
    end
  end

  context '#zero?' do
    it 'is true when the scalar is zero on the base scale' do
      expect(RubyUnits::Unit.new('0')).to be_zero
      expect(RubyUnits::Unit.new('0 mm')).to be_zero
      expect(RubyUnits::Unit.new('-273.15 tempC')).to be_zero
    end

    it 'is false when the scalar is not zero' do
      expect(RubyUnits::Unit.new('1')).not_to be_zero
      expect(RubyUnits::Unit.new('1 mm')).not_to be_zero
      expect(RubyUnits::Unit.new('0 tempC')).not_to be_zero
    end
  end

  context '#succ' do
    specify { expect(RubyUnits::Unit.new('1').succ).to eq(RubyUnits::Unit.new('2')) }
    specify { expect(RubyUnits::Unit.new('1 mm').succ).to eq(RubyUnits::Unit.new('2 mm')) }
    specify { expect(RubyUnits::Unit.new('1 mm').next).to eq(RubyUnits::Unit.new('2 mm')) }
    specify { expect(RubyUnits::Unit.new('-1 mm').succ).to eq(RubyUnits::Unit.new('0 mm')) }
    specify { expect { RubyUnits::Unit.new('1.5 mm').succ }.to raise_error(ArgumentError, 'Non Integer Scalar') }
  end

  context '#pred' do
    specify { expect(RubyUnits::Unit.new('1').pred).to eq(RubyUnits::Unit.new('0')) }
    specify { expect(RubyUnits::Unit.new('1 mm').pred).to eq(RubyUnits::Unit.new('0 mm')) }
    specify { expect(RubyUnits::Unit.new('-1 mm').pred).to eq(RubyUnits::Unit.new('-2 mm')) }
    specify { expect { RubyUnits::Unit.new('1.5 mm').pred }.to raise_error(ArgumentError, 'Non Integer Scalar') }
  end

  context '#divmod' do
    specify { expect(RubyUnits::Unit.new('5 mm').divmod(RubyUnits::Unit.new('2 mm'))).to eq([2, 1]) }
    specify { expect(RubyUnits::Unit.new('1 km').divmod(RubyUnits::Unit.new('2 m'))).to eq([500, 0]) }
    specify { expect { RubyUnits::Unit.new('1 m').divmod(RubyUnits::Unit.new('2 kg')) }.to raise_error(ArgumentError, "Incompatible Units ('1 m' not compatible with '2 kg')") }
  end

  context '#div' do
    specify { expect(RubyUnits::Unit.new('23 m').div(RubyUnits::Unit.new('2 m'))).to eq(11) }
  end

  context '#best_prefix' do
    specify { expect(RubyUnits::Unit.new('1024 KiB').best_prefix).to eq(RubyUnits::Unit.new('1 MiB')) }
    specify { expect(RubyUnits::Unit.new('1000 m').best_prefix).to eq(RubyUnits::Unit.new('1 km')) }
    specify { expect { RubyUnits::Unit.new('0 m').best_prefix }.to_not raise_error }
  end

  context 'Time helper functions' do
    before do
      allow(Time).to receive(:now).and_return(Time.utc(2011, 10, 16))
      allow(DateTime).to receive(:now).and_return(DateTime.civil(2011, 10, 16))
      allow(Date).to receive(:today).and_return(Date.civil(2011, 10, 16))
    end

    context '#since' do
      specify { expect(RubyUnits::Unit.new('min').since(Time.utc(2001, 4, 1, 0, 0, 0))).to eq(RubyUnits::Unit.new('5544000 min')) }
      specify { expect(RubyUnits::Unit.new('min').since(DateTime.civil(2001, 4, 1, 0, 0, 0))).to eq(RubyUnits::Unit.new('5544000 min')) }
      specify { expect(RubyUnits::Unit.new('min').since(Date.civil(2001, 4, 1))).to eq(RubyUnits::Unit.new('5544000 min')) }
      specify { expect { RubyUnits::Unit.new('min').since('4-1-2001') }.to raise_error(ArgumentError, 'Must specify a Time, Date, or DateTime') }
      specify { expect { RubyUnits::Unit.new('min').since(nil) }.to raise_error(ArgumentError, 'Must specify a Time, Date, or DateTime') }
    end

    context '#before' do
      specify { expect(RubyUnits::Unit.new('5 min').before(Time.now)).to eq(Time.utc(2011, 10, 15, 23, 55)) }
      specify { expect(RubyUnits::Unit.new('5 min').before(DateTime.now)).to eq(DateTime.civil(2011, 10, 15, 23, 55)) }
      specify { expect(RubyUnits::Unit.new('5 min').before(Date.today)).to eq(DateTime.civil(2011, 10, 15, 23, 55)) }
      specify { expect { RubyUnits::Unit.new('5 min').before(nil) }.to raise_error(ArgumentError, 'Must specify a Time, Date, or DateTime') }
      specify { expect { RubyUnits::Unit.new('5 min').before('12:00') }.to raise_error(ArgumentError, 'Must specify a Time, Date, or DateTime') }
    end

    context '#ago' do
      specify { expect(RubyUnits::Unit.new('5 min').ago).to be_kind_of Time }
      specify { expect(RubyUnits::Unit.new('10000 y').ago).to be_kind_of Time }
      specify { expect(RubyUnits::Unit.new('1 year').ago).to eq(Time.utc(2010, 10, 16)) }
    end

    context '#until' do
      specify { expect(RubyUnits::Unit.new('min').until(Date.civil(2011, 10, 17))).to eq(RubyUnits::Unit.new('1440 min')) }
      specify { expect(RubyUnits::Unit.new('min').until(DateTime.civil(2011, 10, 21))).to eq(RubyUnits::Unit.new('7200 min')) }
      specify { expect(RubyUnits::Unit.new('min').until(Time.utc(2011, 10, 21))).to eq(RubyUnits::Unit.new('7200 min')) }
      specify { expect { RubyUnits::Unit.new('5 min').until(nil) }.to raise_error(ArgumentError, 'Must specify a Time, Date, or DateTime') }
      specify { expect { RubyUnits::Unit.new('5 min').until('12:00') }.to raise_error(ArgumentError, 'Must specify a Time, Date, or DateTime') }
    end

    context '#from' do
      specify { expect(RubyUnits::Unit.new('1 day').from(Date.civil(2011, 10, 17))).to eq(Date.civil(2011, 10, 18)) }
      specify { expect(RubyUnits::Unit.new('5 min').from(DateTime.civil(2011, 10, 21))).to eq(DateTime.civil(2011, 10, 21, 0, 5)) }
      specify { expect(RubyUnits::Unit.new('5 min').from(Time.utc(2011, 10, 21))).to eq(Time.utc(2011, 10, 21, 0, 5)) }
      specify { expect { RubyUnits::Unit.new('5 min').from(nil) }.to raise_error(ArgumentError, 'Must specify a Time, Date, or DateTime') }
      specify { expect { RubyUnits::Unit.new('5 min').from('12:00') }.to raise_error(ArgumentError, 'Must specify a Time, Date, or DateTime') }
    end
  end
end

describe 'Unit Output formatting' do
  context RubyUnits::Unit.new('10.5 m/s^2') do
    specify { expect(subject.to_s).to eq('10.5 m/s^2') }
    specify { expect(subject.to_s('%0.2f')).to eq('10.50 m/s^2') }
    specify { expect(subject.to_s('%0.2e km/s^2')).to eq('1.05e-02 km/s^2') }
    specify { expect(subject.to_s('km/s^2')).to eq('0.0105 km/s^2') }
    specify { expect(subject.to_s(STDOUT)).to eq('10.5 m/s^2') }
    specify { expect { subject.to_s('random string') }.to raise_error(ArgumentError, "'random' Unit not recognized") }
  end

  context 'for a unit with a custom display_name' do
    before(:each) do
      Unit.redefine!('cup') do |cup|
        cup.display_name = 'cupz'
      end
    end

    after(:each) do
      Unit.redefine!('cup') do |cup|
        cup.display_name = cup.aliases.first
      end
    end

    subject { Unit.new('8 cups') }

    specify { expect(subject.to_s).to eq('8 cupz') }
  end
end

describe 'Equations with Units' do
  context 'Ideal Gas Law' do
    let(:p) { RubyUnits::Unit.new('100 kPa') }
    let(:v) { RubyUnits::Unit.new('1 m^3') }
    let(:n) { RubyUnits::Unit.new('1 mole') }
    let(:r) { RubyUnits::Unit.new('8.31451 J/mol*degK') }
    specify { expect(((p * v) / (n * r)).convert_to('tempK')).to be_within(RubyUnits::Unit.new('0.1 degK')).of(RubyUnits::Unit.new('12027.2 tempK')) }
  end
end

describe 'Unit hash method' do
  context 'should return equal values for identical units' do
    let(:kg_unit_1) { RubyUnits::Unit.new('2.2 kg') }
    let(:kg_unit_2) { RubyUnits::Unit.new('2.2 kg') }

    specify { expect(kg_unit_1).to eq(kg_unit_2) }
    specify { expect(kg_unit_1.hash).to eq(kg_unit_2.hash) }
    specify { expect([kg_unit_1, kg_unit_2].uniq.size).to eq(1) }
  end

  context 'should return not equal values for differnet units' do
    let(:kg_unit) { RubyUnits::Unit.new('2.2 kg') }
    let(:lb_unit) { RubyUnits::Unit.new('2.2 lbs') }

    specify { expect(kg_unit).to_not eq(lb_unit) }
    specify { expect(kg_unit.hash).to_not eq(lb_unit.hash) }
    specify { expect([kg_unit, lb_unit].uniq.size).to eq(2) }
  end
end
