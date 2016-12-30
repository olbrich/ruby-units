require File.dirname(__FILE__) + '/../spec_helper'

describe Math do
  describe '#sqrt' do
    specify { expect(Math.sqrt(RubyUnits::Unit.new('1 mm^6'))).to eq(RubyUnits::Unit.new('1 mm^3')) }
    specify { expect(Math.sqrt(4)).to eq(2) }
    specify { expect(Math.sqrt(RubyUnits::Unit.new('-9 mm^2')).scalar).to be_kind_of(Complex) }
  end

  describe '#cbrt' do
    specify { expect(Math.cbrt(RubyUnits::Unit.new('1 mm^6'))).to eq(RubyUnits::Unit.new('1 mm^2')) }
    specify { expect(Math.cbrt(8)).to eq(2) }
  end

  context 'Trigonometry functions' do
    context "with '45 deg' unit" do
      subject { RubyUnits::Unit.new('45 deg') }
      specify { expect(Math.sin(subject)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.cos(subject)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.tan(subject)).to be_within(0.01).of(1) }
      specify { expect(Math.sinh(subject)).to be_within(0.01).of(0.8686709614860095) }
      specify { expect(Math.cosh(subject)).to be_within(0.01).of(1.3246090892520057) }
      specify { expect(Math.tanh(subject)).to be_within(0.01).of(0.6557942026326724) }
    end

    context "with 'PI/4 radians' unit" do
      subject { RubyUnits::Unit.new((Math::PI / 4), 'radians') }
      specify { expect(Math.sin(subject)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.cos(subject)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.tan(subject)).to be_within(0.01).of(1) }
      specify { expect(Math.sinh(subject)).to be_within(0.01).of(0.8686709614860095) }
      specify { expect(Math.cosh(subject)).to be_within(0.01).of(1.3246090892520057) }
      specify { expect(Math.tanh(subject)).to be_within(0.01).of(0.6557942026326724) }
    end

    context "with 'PI/4' continues to work" do
      subject { (Math::PI / 4) }
      specify { expect(Math.sin(subject)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.cos(subject)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.tan(subject)).to be_within(0.01).of(1) }
      specify { expect(Math.sinh(subject)).to be_within(0.01).of(0.8686709614860095) }
      specify { expect(Math.cosh(subject)).to be_within(0.01).of(1.3246090892520057) }
      specify { expect(Math.tanh(subject)).to be_within(0.01).of(0.6557942026326724) }
    end

    specify do
      expect(
        Math.hypot(
          RubyUnits::Unit.new('1 m'),
          RubyUnits::Unit.new('2 m')
        )
      ).to be_within(RubyUnits::Unit.new('0.01 m')).of(RubyUnits::Unit.new('2.23607 m'))
    end
    specify do
      expect(
        Math.hypot(
          RubyUnits::Unit.new('1 m'),
          RubyUnits::Unit.new('2 ft')
        )
      ).to be_within(RubyUnits::Unit.new('0.01 m')).of(RubyUnits::Unit.new('1.17116 m'))
    end
    specify { expect(Math.hypot(3, 4)).to eq(5) }
    specify do
      expect do
        Math.hypot(
          RubyUnits::Unit.new('1 m'),
          RubyUnits::Unit.new('2 lbs')
        )
      end.to raise_error(ArgumentError)
    end

    specify do
      expect(Math.atan2(RubyUnits::Unit.new('1 m'), RubyUnits::Unit.new('2 m'))).to be_within(0.01).of(0.4636476090008061)
    end
    specify do
      expect(Math.atan2(RubyUnits::Unit.new('1 m'), RubyUnits::Unit.new('2 ft'))).to be_within(0.01).of(1.0233478888629426)
    end
    specify { expect(Math.atan2(1, 1)).to be_within(0.01).of(0.785398163397448) }
    specify { expect { Math.atan2(RubyUnits::Unit.new('1 m'), RubyUnits::Unit.new('2 lbs')) }.to raise_error(ArgumentError) }
  end
end
