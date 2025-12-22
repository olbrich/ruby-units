# frozen_string_literal: true

RSpec.describe RubyUnits::Math do
  describe "#sqrt" do
    specify { expect(Math.sqrt(RubyUnits::Unit.new("1 mm^6"))).to eq(RubyUnits::Unit.new("1 mm^3")) }
    specify { expect(Math.sqrt(4)).to eq(2) }
    specify { expect(Math.sqrt(RubyUnits::Unit.new("-9 mm^2")).scalar).to be_a(Complex) }
  end

  describe "#cbrt" do
    specify { expect(Math.cbrt(RubyUnits::Unit.new("1 mm^6"))).to eq(RubyUnits::Unit.new("1 mm^2")) }
    specify { expect(Math.cbrt(8)).to eq(2) }
  end

  describe "Trigonometry functions" do
    context "with '45 deg' unit" do
      subject(:angle) { RubyUnits::Unit.new("45 deg") }

      specify { expect(Math.sin(angle)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.cos(angle)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.tan(angle)).to be_within(0.01).of(1) }
      specify { expect(Math.sinh(angle)).to be_within(0.01).of(0.8686709614860095) }
      specify { expect(Math.cosh(angle)).to be_within(0.01).of(1.3246090892520057) }
      specify { expect(Math.tanh(angle)).to be_within(0.01).of(0.6557942026326724) }
    end

    context "with 'PI/4 radians' unit" do
      subject(:angle) { RubyUnits::Unit.new(Math::PI / 4, "radians") }

      specify { expect(Math.sin(angle)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.cos(angle)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.tan(angle)).to be_within(0.01).of(1) }
      specify { expect(Math.sinh(angle)).to be_within(0.01).of(0.8686709614860095) }
      specify { expect(Math.cosh(angle)).to be_within(0.01).of(1.3246090892520057) }
      specify { expect(Math.tanh(angle)).to be_within(0.01).of(0.6557942026326724) }
    end

    context "with 'PI/4' continues to work" do
      subject(:number) { (Math::PI / 4) }

      specify { expect(Math.sin(number)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.cos(number)).to be_within(0.01).of(0.70710678) }
      specify { expect(Math.tan(number)).to be_within(0.01).of(1) }
      specify { expect(Math.sinh(number)).to be_within(0.01).of(0.8686709614860095) }
      specify { expect(Math.cosh(number)).to be_within(0.01).of(1.3246090892520057) }
      specify { expect(Math.tanh(number)).to be_within(0.01).of(0.6557942026326724) }
    end

    specify do
      expect(
        Math.hypot(
          RubyUnits::Unit.new("1 m"),
          RubyUnits::Unit.new("2 m")
        )
      ).to be_within(RubyUnits::Unit.new("0.01 m")).of(RubyUnits::Unit.new("2.23607 m"))
    end

    specify do
      expect(
        Math.hypot(
          RubyUnits::Unit.new("1 m"),
          RubyUnits::Unit.new("2 ft")
        )
      ).to be_within(RubyUnits::Unit.new("0.01 m")).of(RubyUnits::Unit.new("1.17116 m"))
    end

    specify { expect(Math.hypot(3, 4)).to eq(5) }

    specify do
      expect do
        Math.hypot(
          RubyUnits::Unit.new("1 m"),
          RubyUnits::Unit.new("2 lbs")
        )
      end.to raise_error(ArgumentError)
    end

    specify do
      expect(
        Math.atan2(
          RubyUnits::Unit.new("1 m"),
          RubyUnits::Unit.new("2 m")
        )
      ).to be_within(RubyUnits::Unit.new("0.1 rad")).of("0.4636476090008061 rad".to_unit)
    end

    specify do
      expect(
        Math.atan2(
          RubyUnits::Unit.new("1 m"),
          RubyUnits::Unit.new("2 ft")
        )
      ).to be_within(RubyUnits::Unit.new("0.1 rad")).of("1.0233478888629426 rad".to_unit)
    end

    specify { expect(Math.atan2(1, 1)).to be_within(0.01).of(0.785398163397448) }
    specify { expect { Math.atan2(RubyUnits::Unit.new("1 m"), RubyUnits::Unit.new("2 lbs")) }.to raise_error(ArgumentError) }
  end

  describe "Inverse trigonometry functions" do
    context "with unit" do
      subject(:unit) { RubyUnits::Unit.new("0.70710678") }

      it { expect(Math.asin(unit)).to be_within(RubyUnits::Unit.new(0.01, "rad")).of("0.785398 rad".to_unit) }
      it { expect(Math.acos(unit)).to be_within(RubyUnits::Unit.new(0.01, "rad")).of("0.785398 rad".to_unit) }
      it { expect(Math.atan(unit)).to be_within(RubyUnits::Unit.new(0.01, "rad")).of("0.61548 rad".to_unit) }
    end

    context "with a Numeric continues to work" do
      subject(:number) { 0.70710678 }

      it { expect(Math.asin(number)).to be_within(0.01).of(0.785398163397448) }
      it { expect(Math.acos(number)).to be_within(0.01).of(0.785398163397448) }
      it { expect(Math.atan(number)).to be_within(0.01).of(0.615479708670387) }
    end
  end

  describe "Exponential and logarithmic functions" do
    context "with a unit" do
      subject(:unit) { RubyUnits::Unit.new("2") }

      it { expect(Math.exp(unit)).to be_within(RubyUnits::Unit.new(0.01)).of("7.389056".to_unit) }
      it { expect(Math.log(unit)).to be_within(RubyUnits::Unit.new(0.01)).of("0.6931471805599453".to_unit) }
      it { expect(Math.log10(unit)).to be_within(RubyUnits::Unit.new(0.01)).of("0.3010299956639812".to_unit) }
    end

    context "with a Numeric continues to work" do
      subject(:number) { 2 }

      it { expect(Math.exp(number)).to be_within(0.01).of(7.38905609893065) }
      it { expect(Math.log(number)).to be_within(0.01).of(0.693147180559945) }
      it { expect(Math.log10(number)).to be_within(0.01).of(0.301029995663981) }
    end
  end
end
