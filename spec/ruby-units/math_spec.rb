require File.dirname(__FILE__) + '/../spec_helper'

describe Math do

  describe "#sqrt" do
    specify { expect(Math.sqrt(Unit('1 mm^6'))).to eq(Unit('1 mm^3')) }
    specify { expect(Math.sqrt(4)).to eq(2) }
    specify { expect(Math.sqrt(Unit("-9 mm^2"))).to be_kind_of(Complex) }
  end

  describe '#cbrt' do
    specify { expect(Math.cbrt(Unit('1 mm^6'))).to eq(Unit('1 mm^2')) }
    specify { expect(Math.cbrt(8)).to eq(2) }
  end

  context "Trigonometry functions" do

    context "with '45 deg' unit" do
      subject { Unit("45 deg") }
      specify { expect(Math.sin(subject)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.cos(subject)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.tan(subject)).to be_within(0.01).of(1) }
      specify { expect(Math.sinh(subject)).to be_within(0.01).of(0.8686709614860095) }
      specify { expect(Math.cosh(subject)).to be_within(0.01).of(1.3246090892520057) }
      specify { expect(Math.tanh(subject)).to be_within(0.01).of(0.6557942026326724) }
    end

    context "with 'PI/4 radians' unit" do
      subject { Unit((Math::PI/4),'radians') }
      specify { expect(Math.sin(subject)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.cos(subject)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.tan(subject)).to be_within(0.01).of(1) }
      specify { expect(Math.sinh(subject)).to be_within(0.01).of(0.8686709614860095) }
      specify { expect(Math.cosh(subject)).to be_within(0.01).of(1.3246090892520057) }
      specify { expect(Math.tanh(subject)).to be_within(0.01).of(0.6557942026326724) }
    end

    context "with 'PI/4' continues to work" do
      subject { (Math::PI/4) }
      specify { expect(Math.sin(subject)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.cos(subject)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.tan(subject)).to be_within(0.01).of(1) }
      specify { expect(Math.sinh(subject)).to be_within(0.01).of(0.8686709614860095) }
      specify { expect(Math.cosh(subject)).to be_within(0.01).of(1.3246090892520057) }
      specify { expect(Math.tanh(subject)).to be_within(0.01).of(0.6557942026326724) }
    end

    specify { expect(Math.hypot(Unit("1 m"), Unit("2 m"))).to be_within(Unit("0.01 m")).of(Unit("2.23607 m")) }
    specify { expect(Math.hypot(Unit("1 m"), Unit("2 ft"))).to be_within(Unit("0.01 m")).of(Unit("1.17116 m")) }
    specify { expect(Math.hypot(3,4)).to eq(5)}
    specify { expect {Math.hypot(Unit("1 m"), Unit("2 lbs")) }.to raise_error(ArgumentError) }

    specify { expect(Math.atan2(Unit("1 m"), Unit("2 m"))).to be_within(0.01).of(0.4636476090008061) }
    specify { expect(Math.atan2(Unit("1 m"), Unit("2 ft"))).to be_within(0.01).of(1.0233478888629426) }
    specify { expect(Math.atan2(1,1)).to be_within(0.01).of(0.785398163397448)}
    specify { expect {Math.atan2(Unit("1 m"), Unit("2 lbs"))}.to raise_error(ArgumentError) }
  end
end
