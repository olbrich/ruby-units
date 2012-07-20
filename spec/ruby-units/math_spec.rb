require File.dirname(__FILE__) + '/../spec_helper'

describe Math do

  describe "#sqrt" do
    specify { Math.sqrt(Unit('1 mm^6')).should == Unit('1 mm^3') }
    specify { Math.sqrt(4).should == 2 }
    specify { Math.sqrt(Unit("-9 mm^2")).should be_kind_of(Complex) } if defined?(Complex)
  end

  if RUBY_VERSION > "1.9"
  # cbrt is only defined in Ruby > 1.9
    describe '#cbrt' do
      specify { Math.cbrt(Unit('1 mm^6')).should == Unit('1 mm^2') }
      specify { Math.cbrt(8).should == 2 }
    end
  end

  context "Trigonometry functions" do

    context "with '45 deg' unit" do
      subject { Unit("45 deg") }
      specify { Math.sin(subject).should be_within(0.01).of(0.70710678) }
      specify { Math.cos(subject).should be_within(0.01).of(0.70710678) }
      specify { Math.tan(subject).should be_within(0.01).of(1) }
      specify { Math.sinh(subject).should be_within(0.01).of(0.8686709614860095) }
      specify { Math.cosh(subject).should be_within(0.01).of(1.3246090892520057) }
      specify { Math.tanh(subject).should be_within(0.01).of(0.6557942026326724) }
    end

    context "with 'PI/4 radians' unit" do
      subject { Unit((Math::PI/4),'radians') }
      specify { Math.sin(subject).should be_within(0.01).of(0.70710678) }
      specify { Math.cos(subject).should be_within(0.01).of(0.70710678) }
      specify { Math.tan(subject).should be_within(0.01).of(1) }
      specify { Math.sinh(subject).should be_within(0.01).of(0.8686709614860095) }
      specify { Math.cosh(subject).should be_within(0.01).of(1.3246090892520057) }
      specify { Math.tanh(subject).should be_within(0.01).of(0.6557942026326724) }
    end

    context "with 'PI/4' continues to work" do
      subject { (Math::PI/4) }
      specify { Math.sin(subject).should be_within(0.01).of(0.70710678) }
      specify { Math.cos(subject).should be_within(0.01).of(0.70710678) }
      specify { Math.tan(subject).should be_within(0.01).of(1) }
      specify { Math.sinh(subject).should be_within(0.01).of(0.8686709614860095) }
      specify { Math.cosh(subject).should be_within(0.01).of(1.3246090892520057) }
      specify { Math.tanh(subject).should be_within(0.01).of(0.6557942026326724) }
    end

    specify { Math.hypot(Unit("1 m"), Unit("2 m")).should be_within(Unit("0.01 m")).of(Unit("2.23607 m")) }
    specify { Math.hypot(Unit("1 m"), Unit("2 ft")).should be_within(Unit("0.01 m")).of(Unit("1.17116 m")) }
    specify { Math.hypot(3,4).should == 5}
    specify { expect {Math.hypot(Unit("1 m"), Unit("2 lbs")) }.to raise_error(ArgumentError) }

    specify { Math.atan2(Unit("1 m"), Unit("2 m")).should be_within(0.01).of(0.4636476090008061) }
    specify { Math.atan2(Unit("1 m"), Unit("2 ft")).should be_within(0.01).of(1.0233478888629426) }
    specify { Math.atan2(1,1).should be_within(0.01).of(0.785398163397448)}
    specify { expect {Math.atan2(Unit("1 m"), Unit("2 lbs"))}.to raise_error(ArgumentError) }
  end
end
