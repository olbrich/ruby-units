require File.dirname(__FILE__) + '/../spec_helper'
require 'yaml'

describe Unit.base_units do
  it { is_expected.to be_a Array }
  it 'has 14 elements' do
    expect(subject.size).to eq(14)
  end
  %w{kilogram meter second ampere degK tempK mole candela each dollar steradian radian decibel byte}.each do |u|
    it { is_expected.to include(Unit(u)) }
  end
end


describe "Create some simple units" do

  # zero string
  describe Unit("0") do
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
  describe Unit("1") do
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
  describe Unit(1) do
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
  describe Unit(Rational(1, 2)) do
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
  describe Unit(0.5) do
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
  describe Unit(Complex(1, 1)) do
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

  describe Unit("1+1i m") do
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
      it { is_expected.to eq("m") }
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
  describe Unit("1 mm") do
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
      it { is_expected.to eq("mm") }
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
      it { is_expected.to eq(Unit("0.001 m")) }
    end
  end

  # with a zero power
  describe Unit("1 m^0") do
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
      it { is_expected.to eq("") }
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
      it { is_expected.to eq(Unit("1")) }
    end
  end

  # unit only
  describe Unit("mm") do
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
      it { is_expected.to eq("mm") }
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
      it { is_expected.to eq(Unit("0.001 m")) }
    end
  end

  # Compound unit
  describe Unit("1 N*m") do
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
      it { is_expected.to eq("N*m") }
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
      it { is_expected.to eq(Unit("1 kg*m^2/s^2")) }
    end
  end

  # scalar and unit with powers
  describe Unit("10 m/s^2") do
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
      it { is_expected.to eq("m/s^2") }
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
      it { is_expected.to eq(Unit("10 m/s^2")) }
    end
  end

  # feet/in form
  describe Unit("5ft 6in") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to eq(5.5) }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("ft") }
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
      it { is_expected.to be_within(Unit("0.01 m")).of Unit("1.6764 m") }
    end
    specify { expect(subject.to_s(:ft)).to eq(%{5'6"}) }
  end

  # pound/ounces form
  describe Unit("6lbs 5oz") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_within(0.001).of 6.312 }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("lbs") }
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
      it { is_expected.to be_within(Unit("0.01 kg")).of Unit("2.8633 kg") }
    end
    specify { expect(subject.to_s(:lbs)).to eq("6 lbs, 5 oz") }
  end

  # temperature
  describe Unit("100 tempC") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_within(0.001).of 100 }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("tempC") }
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
      it { is_expected.to be_within(Unit("0.01 degK")).of Unit("373.15 tempK") }
    end

    describe '#temperature_scale' do
      subject { super().temperature_scale }
      it { is_expected.to eq("degC") }
    end
  end

  # Time
  describe Unit(Time.now) do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_a(Numeric) }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("s") }
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
  describe Unit("100 degC") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_within(0.001).of 100 }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("degC") }
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
      it { is_expected.to be_within(Unit("0.01 degK")).of Unit("100 degK") }
    end
  end

  # percent
  describe Unit("75%") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("%") }
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
  describe Unit("180 deg") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_a Numeric }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("deg") }
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
  describe Unit("1 radian") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_a Numeric }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("rad") }
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
  describe Unit("12 dozen") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("doz") }
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
  describe Unit("1/2 kg") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Rational }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("kg") }
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

  # rational scalar with compound unit
  describe Unit("1/2 kg/m") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Rational }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("kg/m") }
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
  describe Unit("12.1 mg/0.6mL") do
    it { should be_an_instance_of Unit }
    its(:scalar) { should be_an Numeric}
    its(:units) { should == "mg/ml" }
    its(:kind) { should == :density }
    it { should_not be_temperature }
    it { should_not be_degree }
    it { should_not be_base }
    it { should_not be_unitless }
    it { should_not be_zero }
    its(:base) { should be_a Numeric }
    its(:temperature_scale) { should be_nil }
  end

  # time string
  describe Unit("1:23:45,200") do
    it { is_expected.to be_an_instance_of Unit }
    it { is_expected.to eq(Unit("1 h") + Unit("23 min") + Unit("45 seconds") + Unit("200 usec")) }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Rational }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("h") }
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
  describe Unit.parse("1 hour in minutes") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("min") }
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
  describe Unit("1 attoparsec/microfortnight") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("apc/ufortnight") }
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
    it { expect(subject.convert_to("in/s")).to be_within(Unit("0.0001 in/s")).of(Unit("1.0043269330917 in/s")) }
  end

  # Farads
  describe Unit("1 F") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("F") }
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

  describe Unit("1 m^2 s^-2") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("m^2/s^2") }
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

  describe Unit(1, "m^2", "s^2") do
    it { is_expected.to be_an_instance_of Unit }

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to be_an Integer }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("m^2/s^2") }
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

  #scientific notation
  describe Unit("1e6 cells") do
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
      it { is_expected.to eq("cells") }
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

  #could be m*m
  describe Unit("1 mm") do
    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:length) }
    end
  end

  #could be centi-day
  describe Unit("1 cd") do
    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:luminous_power) }
    end
  end

  # could be milli-inch
  describe Unit("1 min") do
    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:time) }
    end
  end

  #could be femto-tons
  describe Unit("1 ft") do
    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:length) }
    end
  end

  #could be deci-ounce
  describe Unit("1 doz") do
    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:unitless) }
    end
  end

  # create with another unit
  describe 10.unit(Unit("1 mm")) do
    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("mm") }
    end

    describe '#scalar' do
      subject { super().scalar }
      it { is_expected.to eq(10) }
    end
  end

  #explicit create
  describe Unit("1 <meter>/<second>") do
    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:speed) }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("m/s") }
    end
  end

  describe Unit("1 <kilogram><meter>/<second><second><second>") do
    describe '#kind' do
      subject { super().kind }
      it { is_expected.to eq(:yank) }
    end

    describe '#units' do
      subject { super().units }
      it { is_expected.to eq("kg*m/s^3") }
    end
  end

  # without spaces
  describe Unit('1g') do
    specify { expect(subject).to eq(Unit('1 g')) }
  end

  describe Unit('-1g') do
    specify { expect(subject).to eq(Unit('-1 g')) }
  end

  describe Unit('11/s') do
    specify { expect(subject).to eq(Unit('11 1/s')) }
  end

  describe Unit.new("63.5029318kg") do
    specify { expect(subject).to eq(Unit.new("63.5029318 kg")) }
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
    specify { expect(subject).to eq(Unit.new('100 ug'))}
  end

  describe Unit.new('100 mcL') do
    specify { expect(subject).to eq(Unit.new('100 uL'))}
  end

end

describe "Unit handles attempts to create bad units" do
  specify "no empty strings" do
    expect { Unit("") }.to raise_error(ArgumentError, "No Unit Specified")
  end

  specify "no blank strings" do
    expect { Unit("   ") }.to raise_error(ArgumentError, "No Unit Specified")
  end

  specify "no strings with tabs" do
    expect { Unit("\t") }.to raise_error(ArgumentError, "No Unit Specified")
  end

  specify "no strings with newlines" do
    expect { Unit("\n") }.to raise_error(ArgumentError, "No Unit Specified")
  end

  specify "no double slashes" do
    expect { Unit("3 s/s/ft") }.to raise_error(ArgumentError, /Unit not recognized/)
  end

  specify "no pipes or commas" do
    expect { Unit("3 s**2|,s**2") }.to raise_error(ArgumentError, /Unit not recognized/)
  end

  specify "no multiple spaces" do
    expect { Unit("3 s**2 4s s**2") }.to raise_error(ArgumentError, /Unit not recognized/)
  end

  specify "no exponentiation of numbers" do
    expect { Unit("3 s 5^6") }.to raise_error(ArgumentError, /Unit not recognized/)
  end

  specify "no strings that don't specify a valid unit" do
    expect { Unit("random string") }.to raise_error(ArgumentError, "'random string' Unit not recognized")
  end

  specify "no unhandled classes" do
    expect { Unit(STDIN) }.to raise_error(ArgumentError, "Invalid Unit Format")
  end

  specify "no undefined units" do
    expect { Unit("1 mFoo") }.to raise_error(ArgumentError, "'1 mFoo' Unit not recognized")
    expect { Unit("1 second/mFoo") }.to raise_error(ArgumentError, "'1 second/mFoo' Unit not recognized")
  end

  specify "no units with powers greater than 19" do
    expect { Unit("1 m^20") }.to raise_error(ArgumentError, "Power out of range (-20 < net power of a unit < 20)")
  end

  specify "no units with powers less than 19" do
    expect { Unit("1 m^-20") }.to raise_error(ArgumentError, "Power out of range (-20 < net power of a unit < 20)")
  end

  specify "no temperatures less than absolute zero" do
    expect { Unit("-100 tempK") }.to raise_error(ArgumentError, "Temperatures must not be less than absolute zero")
    expect { Unit("-100 tempR") }.to raise_error(ArgumentError, "Temperatures must not be less than absolute zero")
    expect { Unit("-500/9 tempR") }.to raise_error(ArgumentError, "Temperatures must not be less than absolute zero")
  end

  specify "no nil scalar" do
    expect { Unit(nil, "feet") }.to raise_error(ArgumentError, "Invalid Unit Format")
    expect { Unit(nil, "feet", "min") }.to raise_error(ArgumentError, "Invalid Unit Format")
  end

  specify 'no double prefixes' do
    expect { Unit.new('1 mmm') }.to raise_error(ArgumentError, /Unit not recognized/)
  end

end

describe Unit do
  it "is a subclass of Numeric" do
    expect(described_class).to be < Numeric
  end

  it "is Comparable" do
    expect(described_class).to be < Comparable
  end

  describe "#defined?" do
    it "should return true when asked about a defined unit" do
      expect(Unit.defined?("meter")).to be_truthy
    end

    it "should return true when asked about an alias for a unit" do
      expect(Unit.defined?("m")).to be_truthy
    end

    it "should return false when asked about a unit that is not defined" do
      expect(Unit.defined?("doohickey")).to be_falsey
    end
  end

  describe '#to_yaml' do
    subject { Unit('1 mm') }

    describe '#to_yaml' do
      subject { super().to_yaml }
      it { is_expected.to match(/--- !ruby\/object:RubyUnits::Unit/) }
    end
  end

  describe "#definition" do
    context "The requested unit is defined" do
      before(:each) do
        @definition = Unit.definition('mph')
      end

      it "should return a Unit::Definition" do
        expect(@definition).to be_instance_of(Unit::Definition)
      end

      specify { expect(@definition.name).to eq("<mph>") }
      specify { expect(@definition.aliases).to eq(%w{mph}) }
      specify { expect(@definition.numerator).to eq(['<meter>']) }
      specify { expect(@definition.denominator).to eq(['<second>']) }
      specify { expect(@definition.kind).to eq(:speed) }
      specify { expect(@definition.scalar).to be === 0.44704 }
    end

    context "The requested unit is not defined" do
      it "should return nil" do
        expect(Unit.definition("doohickey")).to be_nil
      end
    end
  end

  describe "#define" do
    describe "a new unit" do
      before(:each) do
        @jiffy = Unit.define("jiffy") do |jiffy|
          jiffy.scalar = (1/100)
          jiffy.aliases = %w{jif}
          jiffy.numerator = ["<second>"]
          jiffy.kind = :time
        end
      end

      after(:each) do
        Unit.undefine!('jiffy')
      end

      describe "Unit('1e6 jiffy')" do
        # do this because the unit is not defined at the time this file is parsed, so it fails
        subject { Unit("1e6 jiffy") }

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
          it { is_expected.to eq("jif") }
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
          it { is_expected.to eq(Unit("10000 s")) }
        end
      end

      it "should register the new unit" do
        expect(Unit.defined?('jiffy')).to be_truthy
      end
    end

    describe "an existing unit again" do
      before(:each) do
        @cups = Unit.definition('cup')
        @original_display_name = @cups.display_name
        @cups.display_name = "cupz"
        Unit.define(@cups)
      end

      after(:each) do
        Unit.redefine!("cup") do |cup|
          cup.display_name = @original_display_name
        end
      end

      describe "Unit('1 cup')" do
        # do this because the unit is going to be redefined
        subject { Unit("1 cup") }

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
          it { is_expected.to eq("cupz") }
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
      @jiffy = Unit.define("jiffy") do |jiffy|
        jiffy.scalar = (1/100)
        jiffy.aliases = %w{jif}
        jiffy.numerator = ["<second>"]
        jiffy.kind = :time
      end

      Unit.redefine!('jiffy') do |jiffy|
        jiffy.scalar = (1/1000)
      end
    end

    after(:each) do
      Unit.undefine!("jiffy")
    end

    specify { expect(Unit('1 jiffy').to_base.scalar).to eq(1/1000) }
  end

  describe '#undefine!' do
    before(:each) do
      @jiffy = Unit.define("jiffy") do |jiffy|
        jiffy.scalar = (1/100)
        jiffy.aliases = %w{jif}
        jiffy.numerator = ["<second>"]
        jiffy.kind = :time
      end
      Unit.undefine!("jiffy")
    end

    specify "the unit should be undefined" do
      expect(Unit.defined?('jiffy')).to be_falsey
    end

    specify "attempting to use an undefined unit fails" do
      expect { Unit("1 jiffy") }.to raise_exception(ArgumentError)
    end

    it "should return true when undefining an unknown unit" do
      expect(Unit.defined?("unknown")).to be_falsey
      expect(Unit.undefine!("unknown")).to be_truthy
    end

  end

  describe '#clone' do
    subject { Unit('1 mm') }

    describe '#clone' do
      subject { super().clone }
      it { is_expected.to be === subject }
    end
  end
end

describe "Unit Comparisons" do
  context "Unit should detect if two units are 'compatible' (i.e., can be converted into each other)" do
    specify { expect(Unit("1 ft") =~ Unit('1 m')).to be true }
    specify { expect(Unit("1 ft") =~ "m").to be true }
    specify { expect(Unit("1 ft")).to be_compatible_with Unit('1 m') }
    specify { expect(Unit("1 ft")).to be_compatible_with "m" }
    specify { expect(Unit("1 m")).to be_compatible_with Unit('1 kg*m/kg') }
    specify { expect(Unit("1 ft") =~ Unit('1 kg')).to be false }
    specify { expect(Unit("1 ft")).not_to be_compatible_with Unit('1 kg') }
    specify { expect(Unit("1 ft")).not_to be_compatible_with nil }
  end

  context "Equality" do

    context "with uncoercable objects" do
      specify { expect(Unit("1 mm")).not_to eq(nil) }
    end

    context "units of same kind" do
      specify { expect(Unit("1000 m")).to eq(Unit('1 km')) }
      specify { expect(Unit("100 m")).not_to eq(Unit('1 km')) }
      specify { expect(Unit("1 m")).to eq(Unit('100 cm')) }
    end

    context "units of incompatible types" do
      specify { expect(Unit("1 m")).not_to eq(Unit("1 kg")) }
    end

    context "units with a zero scalar are equal" do
      specify { expect(Unit("0 m")).to eq(Unit("0 s")) }
      specify { expect(Unit("0 m")).to eq(Unit("0 kg")) }

      context "except for temperature units" do
        specify { expect(Unit("0 tempK")).to eq(Unit("0 m")) }
        specify { expect(Unit("0 tempR")).to eq(Unit("0 m")) }
        specify { expect(Unit("0 tempC")).not_to eq(Unit("0 m")) }
        specify { expect(Unit("0 tempF")).not_to eq(Unit("0 m")) }
      end
    end
  end

  context "Equivalence" do
    context "units and scalars are the exactly the same" do
      specify { expect(Unit("1 m")).to be === Unit("1 m") }
      specify { expect(Unit("1 m")).to be_same Unit("1 m") }
      specify { expect(Unit("1 m")).to be_same_as Unit("1 m") }
    end

    context "units are compatible but not identical" do
      specify { expect(Unit("1000 m")).not_to be === Unit("1 km") }
      specify { expect(Unit("1000 m")).not_to be_same Unit("1 km") }
      specify { expect(Unit("1000 m")).not_to be_same_as Unit("1 km") }
    end

    context "units are not compatible" do
      specify { expect(Unit("1000 m")).not_to be === Unit("1 hour") }
      specify { expect(Unit("1000 m")).not_to be_same Unit("1 hour") }
      specify { expect(Unit("1000 m")).not_to be_same_as Unit("1 hour") }
    end

    context "scalars are different" do
      specify { expect(Unit("1 m")).not_to be === Unit("2 m") }
      specify { expect(Unit("1 m")).not_to be_same Unit("2 m") }
      specify { expect(Unit("1 m")).not_to be_same_as Unit("2 m") }
    end

    specify { expect(Unit("1 m")).not_to be === nil }
  end

  context "Comparisons" do
    context "compatible units can be compared" do
      specify { expect(Unit("1 m")).to be < Unit("2 m") }
      specify { expect(Unit("2 m")).to be > Unit("1 m") }
      specify { expect(Unit("1 m")).to be < Unit("1 mi") }
      specify { expect(Unit("2 m")).to be > Unit("1 ft") }
      specify { expect(Unit("70 tempF")).to be > Unit("10 degC") }
      specify { expect(Unit("1 m")).to be > 0 }
      specify { expect { expect(Unit("1 m")).not_to be > nil }.to raise_error(ArgumentError, /comparison of RubyUnits::Unit with (nil failed|NilClass)/) }
    end

    context "incompatible units cannot be compared" do
      specify { expect { Unit("1 m") < Unit("1 liter") }.to raise_error(ArgumentError, "Incompatible Units ('m' not compatible with 'l')") }
      specify { expect { Unit("1 kg") > Unit("60 mph") }.to raise_error(ArgumentError, "Incompatible Units ('kg' not compatible with 'mph')") }
    end

    context "with coercions should be valid" do
      specify { expect(Unit("1GB") > "500MB").to eq(true) }
      specify { expect(Unit("0.5GB") < "900MB").to eq(true) }
    end
  end

end

describe "Unit Conversions" do

  context "between compatible units" do
    specify { expect(Unit("1 s").convert_to("ns")).to eq(Unit("1e9 ns")) }
    specify { expect(Unit("1 s").convert_to("ns")).to eq(Unit("1e9 ns")) }
    specify { expect(Unit("1 s") >> "ns").to eq(Unit("1e9 ns")) }

    specify { expect(Unit("1 m").convert_to(Unit("ft"))).to be_within(Unit("0.001 ft")).of(Unit("3.28084 ft")) }
  end

  context "between incompatible units" do
    specify { expect { Unit("1 s").convert_to("m") }.to raise_error(ArgumentError, "Incompatible Units ('1 s' not compatible with 'm')") }
  end

  context "given bad input" do
    specify { expect { Unit("1 m").convert_to("random string") }.to raise_error(ArgumentError, "'random string' Unit not recognized") }
    specify { expect { Unit("1 m").convert_to(STDOUT) }.to raise_error(ArgumentError, "Unknown target units") }
  end

  context "between temperature scales" do
    # note that 'temp' units are for temperature readings on a scale, while 'deg' units are used to represent
    # differences between temperatures, offsets, or other differential temperatures.

    specify { expect(Unit("100 tempC")).to be_within(Unit("0.001 degK")).of(Unit("373.15 tempK")) }
    specify { expect(Unit("0 tempC")).to be_within(Unit("0.001 degK")).of(Unit("273.15 tempK")) }
    specify { expect(Unit("37 tempC")).to be_within(Unit("0.01 degK")).of(Unit("310.15 tempK")) }
    specify { expect(Unit("-273.15 tempC")).to eq(Unit("0 tempK")) }

    specify { expect(Unit("212 tempF")).to be_within(Unit("0.001 degK")).of(Unit("373.15 tempK")) }
    specify { expect(Unit("32 tempF")).to be_within(Unit("0.001 degK")).of(Unit("273.15 tempK")) }
    specify { expect(Unit("98.6 tempF")).to be_within(Unit("0.01 degK")).of(Unit("310.15 tempK")) }
    specify { expect(Unit("-459.67 tempF")).to eq(Unit("0 tempK")) }

    specify { expect(Unit("671.67 tempR")).to be_within(Unit("0.001 degK")).of(Unit("373.15 tempK")) }
    specify { expect(Unit("491.67 tempR")).to be_within(Unit("0.001 degK")).of(Unit("273.15 tempK")) }
    specify { expect(Unit("558.27 tempR")).to be_within(Unit("0.01 degK")).of(Unit("310.15 tempK")) }
    specify { expect(Unit("0 tempR")).to eq(Unit("0 tempK")) }

    specify { expect(Unit("100 tempK").convert_to("tempC")).to be_within(U "0.01 degC").of(Unit("-173.15 tempC")) }
    specify { expect(Unit("100 tempK").convert_to("tempF")).to be_within(U "0.01 degF").of(Unit("-279.67 tempF")) }
    specify { expect(Unit("100 tempK").convert_to("tempR")).to be_within(U "0.01 degR").of(Unit("180 tempR")) }

    specify { expect(Unit("1 degC")).to eq(Unit("1 degK")) }
    specify { expect(Unit("1 degF")).to eq(Unit("1 degR")) }
    specify { expect(Unit("1 degC")).to eq(Unit("1.8 degR")) }
    specify { expect(Unit("1 degF")).to be_within(Unit("0.001 degK")).of(Unit("0.5555 degK")) }
  end

  context "reported bugs" do
    specify { expect(Unit("189 Mtonne") * Unit("1189 g/tonne")).to eq(Unit("224721 tonne")) }
    specify { expect((Unit("189 Mtonne") * Unit("1189 g/tonne")).convert_to("tonne")).to eq(Unit("224721 tonne")) }
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
      specify { expect(Unit(inches).convert_to("ft")).to eq(Unit(feet)) }
      specify { expect(Unit(inches).to_s(:ft)).to eq(feet) }
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
      specify { expect(Unit(ounces).convert_to("lbs")).to eq(Unit(pounds)) }
      specify { expect(Unit(ounces).to_s(:lbs)).to eq(pounds) }
    end
  end
end

describe "Unit Math" do
  context "operators:" do
    context "addition (+)" do
      context "between compatible units" do
        specify { expect(Unit("0 m") + Unit("10 m")).to eq(Unit("10 m")) }
        specify { expect(Unit("5 kg") + Unit("10 kg")).to eq(Unit("15 kg")) }
      end

      context "between a zero unit and another unit" do
        specify { expect(Unit("0 kg") + Unit("10 m")).to eq(Unit("10 m")) }
        specify { expect(Unit("0 m") + Unit("10 kg")).to eq(Unit("10 kg")) }
      end

      context "between incompatible units" do
        specify { expect { Unit("10 kg") + Unit("10 m") }.to raise_error(ArgumentError) }
        specify { expect { Unit("10 m") + Unit("10 kg") }.to raise_error(ArgumentError) }
        specify { expect { Unit("10 m") + nil }.to raise_error(ArgumentError) }
      end

      context "a number from a unit" do
        specify { expect { Unit("10 kg") + 1 }.to raise_error(ArgumentError) }
        specify { expect { 10 + Unit("10 kg") }.to raise_error(ArgumentError) }
      end

      context "between a unit and coerceable types" do
        specify { expect(Unit('10 kg') + %w{1 kg}).to eq(Unit('11 kg')) }
        specify { expect(Unit('10 kg') + "1 kg").to eq(Unit('11 kg')) }
      end

      context "between two temperatures" do
        specify { expect { (Unit("100 tempK") + Unit("100 tempK")) }.to raise_error(ArgumentError, "Cannot add two temperatures") }
      end

      context "between a temperature and a degree" do
        specify { expect(Unit("100 tempK") + Unit("100 degK")).to eq(Unit("200 tempK")) }
      end

      context "between a degree and a temperature" do
        specify { expect(Unit("100 degK") + Unit("100 tempK")).to eq(Unit("200 tempK")) }
      end

    end

    context "subtracting (-)" do
      context "compatible units" do
        specify { expect(Unit("0 m") - Unit("10 m")).to eq(Unit("-10 m")) }
        specify { expect(Unit("5 kg") - Unit("10 kg")).to eq(Unit("-5 kg")) }
      end

      context "a unit from a zero unit" do
        specify { expect(Unit("0 kg") - Unit("10 m")).to eq(Unit("-10 m")) }
        specify { expect(Unit("0 m") - Unit("10 kg")).to eq(Unit("-10 kg")) }
      end

      context "incompatible units" do
        specify { expect { Unit("10 kg") - Unit("10 m") }.to raise_error(ArgumentError) }
        specify { expect { Unit("10 m") - Unit("10 kg") }.to raise_error(ArgumentError) }
        specify { expect { Unit("10 m") - nil }.to raise_error(ArgumentError) }
      end

      context "between a unit and coerceable types" do
        specify { expect(Unit('10 kg') - %w{1 kg}).to eq(Unit('9 kg')) }
        specify { expect(Unit('10 kg') - "1 kg").to eq(Unit('9 kg')) }
      end

      context "a number from a unit" do
        specify { expect { Unit("10 kg") - 1 }.to raise_error(ArgumentError) }
        specify { expect { 10 - Unit("10 kg") }.to raise_error(ArgumentError) }
      end

      context "between two temperatures" do
        specify { expect(Unit("100 tempK") - Unit("100 tempK")).to eq(Unit("0 degK")) }
      end

      context "between a temperature and a degree" do
        specify { expect(Unit("100 tempK") - Unit("100 degK")).to eq(Unit("0 tempK")) }
      end

      context "between a degree and a temperature" do
        specify { expect { (Unit("100 degK") - Unit("100 tempK")) }.to raise_error(ArgumentError, "Cannot subtract a temperature from a differential degree unit") }
      end

    end

    context "multiplying (*)" do
      context "between compatible units" do
        specify { expect(Unit("0 m") * Unit("10 m")).to eq(Unit("0 m^2")) }
        specify { expect(Unit("5 kg") * Unit("10 kg")).to eq(Unit("50 kg^2")) }
      end

      context "between incompatible units" do
        specify { expect(Unit("0 m") * Unit("10 kg")).to eq(Unit("0 kg*m")) }
        specify { expect(Unit("5 m") * Unit("10 kg")).to eq(Unit("50 kg*m")) }
        specify { expect { Unit("10 m") * nil }.to raise_error(ArgumentError) }
      end

      context "between a unit and coerceable types" do
        specify { expect(Unit('10 kg') * %w{1 kg}).to eq(Unit('10 kg^2')) }
        specify { expect(Unit('10 kg') * "1 kg").to eq(Unit('10 kg^2')) }
      end

      context "by a temperature" do
        specify { expect { Unit("5 kg") * Unit("100 tempF") }.to raise_exception(ArgumentError) }
      end

      context "by a number" do
        specify { expect(10 * Unit("5 kg")).to eq(Unit("50 kg")) }
      end

    end

    context "dividing (/)" do
      context "compatible units" do
        specify { expect(Unit("0 m") / Unit("10 m")).to eq(Unit(0)) }
        specify { expect(Unit("5 kg") / Unit("10 kg")).to eq(Rational(1, 2)) }
        specify { expect(Unit("5 kg") / Unit("5 kg")).to eq(1) }
      end

      context "incompatible units" do
        specify { expect(Unit("0 m") / Unit("10 kg")).to eq(Unit("0 m/kg")) }
        specify { expect(Unit("5 m") / Unit("10 kg")).to eq(Unit("1/2 m/kg")) }
        specify { expect { Unit("10 m") / nil }.to raise_error(ArgumentError) }
      end

      context "between a unit and coerceable types" do
        specify { expect(Unit('10 kg^2') / %w{1 kg}).to eq(Unit('10 kg')) }
        specify { expect(Unit('10 kg^2') / "1 kg").to eq(Unit('10 kg')) }
      end

      context "by a temperature" do
        specify { expect { Unit("5 kg") / Unit("100 tempF") }.to raise_exception(ArgumentError) }
      end

      context "a number by a unit" do
        specify { expect(10 / Unit("5 kg")).to eq(Unit("2 1/kg")) }
      end

      context "a unit by a number" do
        specify { expect(Unit("5 kg") / 2).to eq(Unit("2.5 kg")) }
      end

      context "by zero" do
        specify { expect { Unit("10 m") / 0 }.to raise_error(ZeroDivisionError) }
        specify { expect { Unit("10 m") / Unit("0 m") }.to raise_error(ZeroDivisionError) }
        specify { expect { Unit("10 m") / Unit("0 kg") }.to raise_error(ZeroDivisionError) }
      end
    end

    context "exponentiating (**)" do

      specify "a temperature raises an execption" do
        expect { Unit("100 tempK")**2 }.to raise_error(ArgumentError, "Cannot raise a temperature to a power")
      end

      context Unit("0 m") do
        it { expect(subject**1).to eq(subject) }
        it { expect(subject**2).to eq(subject) }
      end

      context Unit("1 m") do
        it { expect(subject**0).to eq(1) }
        it { expect(subject**1).to eq(subject) }
        it { expect(subject**(-1)).to eq(1/subject) }
        it { expect(subject**(2)).to eq(Unit("1 m^2")) }
        it { expect(subject**(-2)).to eq(Unit("1 1/m^2")) }
        specify { expect { subject**(1/2) }.to raise_error(ArgumentError, "Illegal root") }
        # because 1 m^(1/2) doesn't make any sense
        specify { expect { subject**(Complex(1, 1)) }.to raise_error(ArgumentError, "exponentiation of complex numbers is not yet supported.") }
        specify { expect { subject**(Unit("1 m")) }.to raise_error(ArgumentError, "Invalid Exponent") }
      end

      context Unit("1 m^2") do
        it { expect(subject**(Rational(1, 2))).to eq(Unit("1 m")) }
        it { expect(subject**(0.5)).to eq(Unit("1 m")) }

        specify { expect { subject**(0.12345) }.to raise_error(ArgumentError, "Not a n-th root (1..9), use 1/n") }
        specify { expect { subject**("abcdefg") }.to raise_error(ArgumentError, "Invalid Exponent") }
      end

    end

    context "modulo (%)" do
      context "compatible units" do
        specify { expect(Unit("2 m") % Unit("1 m")).to eq(0) }
        specify { expect(Unit("5 m") % Unit("2 m")).to eq(1) }
      end

      specify "incompatible units raises an exception" do
        expect { Unit("1 m") % Unit("1 kg") }.to raise_error(ArgumentError, "Incompatible Units ('1 m' not compatible with '1 kg')")
      end
    end

    context "unary negation (-)" do
      specify { expect(-Unit("1 mm")).to eq(Unit("-1 mm")) }
    end

    context "unary plus (+)" do
      specify { expect(+Unit('1 mm')).to eq(Unit('1 mm')) }
    end
  end

  context "#power" do
    subject { Unit("1 m") }
    it "raises an exception when passed a Float argument" do
      expect { subject.power(1.5) }.to raise_error(ArgumentError, "Exponent must an Integer")
    end
    it "raises an exception when passed a Rational argument" do
      expect { subject.power(Rational(1, 2)) }.to raise_error(ArgumentError, "Exponent must an Integer")
    end
    it "raises an exception when passed a Complex argument" do
      expect { subject.power(Complex(1, 2)) }.to raise_error(ArgumentError, "Exponent must an Integer")
    end
    it "raises an exception when called on a temperature unit" do
      expect { Unit("100 tempC").power(2) }.to raise_error(ArgumentError, "Cannot raise a temperature to a power")
    end

    specify { expect(subject.power(-1)).to eq(Unit("1 1/m")) }
    specify { expect(subject.power(0)).to eq(1) }
    specify { expect(subject.power(1)).to eq(subject) }
    specify { expect(subject.power(2)).to eq(Unit("1 m^2")) }

  end

  context "#root" do
    subject { Unit("1 m") }
    it "raises an exception when passed a Float argument" do
      expect { subject.root(1.5) }.to raise_error(ArgumentError, "Exponent must an Integer")
    end
    it "raises an exception when passed a Rational argument" do
      expect { subject.root(Rational(1, 2)) }.to raise_error(ArgumentError, "Exponent must an Integer")
    end
    it "raises an exception when passed a Complex argument" do
      expect { subject.root(Complex(1, 2)) }.to raise_error(ArgumentError, "Exponent must an Integer")
    end
    it "raises an exception when called on a temperature unit" do
      expect { Unit("100 tempC").root(2) }.to raise_error(ArgumentError, "Cannot take the root of a temperature")
    end

    specify { expect(Unit("1 m^2").root(-2)).to eq(Unit("1 1/m")) }
    specify { expect(subject.root(-1)).to eq(Unit("1 1/m")) }
    specify { expect { (subject.root(0)) }.to raise_error(ArgumentError, "0th root undefined") }
    specify { expect(subject.root(1)).to eq(subject) }
    specify { expect(Unit("1 m^2").root(2)).to eq(Unit("1 m")) }

  end

  context "#inverse" do
    specify { expect(Unit("1 m").inverse).to eq(Unit("1 1/m")) }
    specify { expect { Unit("100 tempK").inverse }.to raise_error(ArgumentError, "Cannot divide with temperatures") }
  end

  context "convert to scalars" do
    specify { expect(Unit("10").to_i).to be_kind_of(Integer) }
    specify { expect { Unit("10 m").to_i }.to raise_error(RuntimeError, "Cannot convert '10 m' to Integer unless unitless.  Use Unit#scalar") }

    specify { expect(Unit("10.0").to_f).to be_kind_of(Float) }
    specify { expect { Unit("10.0 m").to_f }.to raise_error(RuntimeError, "Cannot convert '10 m' to Float unless unitless.  Use Unit#scalar") }

    specify { expect(Unit("1+1i").to_c).to be_kind_of(Complex) }
    specify { expect { Unit("1+1i m").to_c }.to raise_error(RuntimeError, "Cannot convert '1.0+1.0i m' to Complex unless unitless.  Use Unit#scalar") }

    specify { expect(Unit("3/7").to_r).to be_kind_of(Rational) }
    specify { expect { Unit("3/7 m").to_r }.to raise_error(RuntimeError, "Cannot convert '3/7 m' to Rational unless unitless.  Use Unit#scalar") }

  end

  context "absolute value (#abs)" do
    context "of a unitless unit" do
      specify "returns the absolute value of the scalar" do
        expect(Unit("-10").abs).to eq(10)
      end
    end

    context "of a unit" do
      specify "returns a unit with the absolute value of the scalar" do
        expect(Unit("-10 m").abs).to eq(Unit("10 m"))
      end
    end
  end

  context "#ceil" do
    context "of a unitless unit" do
      specify "returns the ceil of the scalar" do
        expect(Unit("10.1").ceil).to eq(11)
      end
    end

    context "of a unit" do
      specify "returns a unit with the ceil of the scalar" do
        expect(Unit("10.1 m").ceil).to eq(Unit("11 m"))
      end
    end
  end

  context "#floor" do
    context "of a unitless unit" do
      specify "returns the floor of the scalar" do
        expect(Unit("10.1").floor).to eq(10)
      end
    end

    context "of a unit" do
      specify "returns a unit with the floor of the scalar" do
        expect(Unit("10.1 m").floor).to eq(Unit("10 m"))
      end
    end
  end

  context "#round" do
    context "of a unitless unit" do
      specify "returns the round of the scalar" do
        expect(Unit("10.5").round).to eq(11)
      end
    end

    context "of a unit" do
      specify "returns a unit with the round of the scalar" do
        expect(Unit("10.5 m").round).to eq(Unit("11 m"))
      end
    end
  end

  context "#truncate" do
    context "of a unitless unit" do
      specify "returns the truncate of the scalar" do
        expect(Unit("10.5").truncate).to eq(10)
      end
    end

    context "of a unit" do
      specify "returns a unit with the truncate of the scalar" do
        expect(Unit("10.5 m").truncate).to eq(Unit("10 m"))
      end
    end

    context "of a complex unit" do
      specify "returns a unit with the truncate of the scalar" do
        expect(Unit("10.5 kg*m/s^3").truncate).to eq(Unit("10 kg*m/s^3"))
      end
    end
  end

  context '#zero?' do
    it "is true when the scalar is zero on the base scale" do
      expect(Unit("0")).to be_zero
      expect(Unit("0 mm")).to be_zero
      expect(Unit("-273.15 tempC")).to be_zero
    end

    it "is false when the scalar is not zero" do
      expect(Unit("1")).not_to be_zero
      expect(Unit("1 mm")).not_to be_zero
      expect(Unit("0 tempC")).not_to be_zero
    end
  end

  context '#succ' do
    specify { expect(Unit("1").succ).to eq(Unit("2")) }
    specify { expect(Unit("1 mm").succ).to eq(Unit("2 mm")) }
    specify { expect(Unit("1 mm").next).to eq(Unit("2 mm")) }
    specify { expect(Unit("-1 mm").succ).to eq(Unit("0 mm")) }
    specify { expect { Unit("1.5 mm").succ }.to raise_error(ArgumentError, "Non Integer Scalar") }
  end

  context '#pred' do
    specify { expect(Unit("1").pred).to eq(Unit("0")) }
    specify { expect(Unit("1 mm").pred).to eq(Unit("0 mm")) }
    specify { expect(Unit("-1 mm").pred).to eq(Unit("-2 mm")) }
    specify { expect { Unit("1.5 mm").pred }.to raise_error(ArgumentError, "Non Integer Scalar") }
  end

  context '#divmod' do
    specify { expect(Unit("5 mm").divmod(Unit("2 mm"))).to eq([2, 1]) }
    specify { expect(Unit("1 km").divmod(Unit("2 m"))).to eq([500, 0]) }
    specify { expect { Unit('1 m').divmod(Unit('2 kg')) }.to raise_error(ArgumentError, "Incompatible Units ('1 m' not compatible with '2 kg')") }
  end

  context '#div' do
    specify { expect(Unit('23 m').div(Unit('2 m'))).to eq(11) }
  end

  context '#best_prefix' do
    specify { expect(Unit('1024 KiB').best_prefix).to eq(Unit('1 MiB')) }
    specify { expect(Unit('1000 m').best_prefix).to eq(Unit('1 km')) }
    specify { expect { Unit('0 m').best_prefix }.to_not raise_error }
  end

  context "Time helper functions" do
    before do
      allow(Time).to receive(:now).and_return(Time.utc(2011, 10, 16))
      allow(DateTime).to receive(:now).and_return(DateTime.civil(2011, 10, 16))
      allow(Date).to receive(:today).and_return(Date.civil(2011, 10, 16))
    end

    context '#since' do
      specify { expect(Unit("min").since(Time.utc(2001, 4, 1, 0, 0, 0))).to eq(Unit("5544000 min")) }
      specify { expect(Unit("min").since(DateTime.civil(2001, 4, 1, 0, 0, 0))).to eq(Unit("5544000 min")) }
      specify { expect(Unit("min").since(Date.civil(2001, 4, 1))).to eq(Unit("5544000 min")) }
      specify { expect { Unit("min").since("4-1-2001") }.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime") }
      specify { expect { Unit("min").since(nil) }.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime") }
    end

    context '#before' do
      specify { expect(Unit("5 min").before(Time.now)).to eq(Time.utc(2011, 10, 15, 23, 55)) }
      specify { expect(Unit("5 min").before(DateTime.now)).to eq(DateTime.civil(2011, 10, 15, 23, 55)) }
      specify { expect(Unit("5 min").before(Date.today)).to eq(DateTime.civil(2011, 10, 15, 23, 55)) }
      specify { expect { Unit('5 min').before(nil) }.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime") }
      specify { expect { Unit('5 min').before("12:00") }.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime") }
    end

    context '#ago' do
      specify { expect(Unit("5 min").ago).to be_kind_of Time }
      specify { expect(Unit("10000 y").ago).to be_kind_of Time }
      specify { expect(Unit("1 year").ago).to eq(Time.utc(2010, 10, 16)) }
    end

    context '#until' do
      specify { expect(Unit("min").until(Date.civil(2011, 10, 17))).to eq(Unit("1440 min")) }
      specify { expect(Unit("min").until(DateTime.civil(2011, 10, 21))).to eq(Unit("7200 min")) }
      specify { expect(Unit("min").until(Time.utc(2011, 10, 21))).to eq(Unit("7200 min")) }
      specify { expect { Unit('5 min').until(nil) }.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime") }
      specify { expect { Unit('5 min').until("12:00") }.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime") }
    end

    context '#from' do
      specify { expect(Unit("1 day").from(Date.civil(2011, 10, 17))).to eq(Date.civil(2011, 10, 18)) }
      specify { expect(Unit("5 min").from(DateTime.civil(2011, 10, 21))).to eq(DateTime.civil(2011, 10, 21, 00, 05)) }
      specify { expect(Unit("5 min").from(Time.utc(2011, 10, 21))).to eq(Time.utc(2011, 10, 21, 00, 05)) }
      specify { expect { Unit('5 min').from(nil) }.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime") }
      specify { expect { Unit('5 min').from("12:00") }.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime") }
    end

  end

end

describe "Unit Output formatting" do
  context Unit("10.5 m/s^2") do
    specify { expect(subject.to_s).to eq("10.5 m/s^2") }
    specify { expect(subject.to_s("%0.2f")).to eq("10.50 m/s^2") }
    specify { expect(subject.to_s("%0.2e km/s^2")).to eq("1.05e-02 km/s^2") }
    specify { expect(subject.to_s("km/s^2")).to eq("0.0105 km/s^2") }
    specify { expect(subject.to_s(STDOUT)).to eq("10.5 m/s^2") }
    specify { expect { subject.to_s("random string") }.to raise_error(ArgumentError, "'random' Unit not recognized") }
  end

  context "for a unit with a custom display_name" do
    before(:each) do
      Unit.redefine!("cup") do |cup|
        cup.display_name = "cupz"
      end
    end

    after(:each) do
      Unit.redefine!("cup") do |cup|
        cup.display_name = cup.aliases.first
      end
    end

    subject { Unit("8 cups") }

    specify { expect(subject.to_s).to eq("8 cupz") }

  end

end

describe "Equations with Units" do
  context "Ideal Gas Law" do
    let(:p) { Unit('100 kPa') }
    let(:v) { Unit('1 m^3') }
    let(:n) { Unit("1 mole") }
    let(:r) { Unit("8.31451 J/mol*degK") }
    specify { expect(((p*v)/(n*r)).convert_to('tempK')).to be_within(Unit("0.1 degK")).of(Unit("12027.2 tempK")) }
  end
end
