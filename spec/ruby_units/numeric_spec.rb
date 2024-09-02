# frozen_string_literal: true

require "bigdecimal"

RSpec.describe RubyUnits::Numeric do
  specify { expect(Integer.instance_methods).to include(:to_unit) }
  specify { expect(Float.instance_methods).to include(:to_unit) }
  specify { expect(Complex.instance_methods).to include(:to_unit) }
  specify { expect(Rational.instance_methods).to include(:to_unit) }
  specify { expect(BigDecimal.instance_methods).to include(:to_unit) }

  describe "#to_unit" do
    context "when nothing is passed" do
      it "returns a unitless unit" do
        expect(1.to_unit).to eq(RubyUnits::Unit.new(1))
        expect(1.0.to_unit).to eq(RubyUnits::Unit.new(1.0))
        expect(Complex(1, 1).to_unit).to eq(RubyUnits::Unit.new(Complex(1, 1)))
        expect(Rational(1, 1).to_unit).to eq(RubyUnits::Unit.new(Rational(1, 1)))
        expect(BigDecimal(1).to_unit).to eq(RubyUnits::Unit.new(BigDecimal(1)))
      end
    end

    context "when converting to a unit" do
      it "returns the converted unit" do
        expect(0.1.to_unit("%")).to eq(RubyUnits::Unit.new(10, "%"))
      end

      it "raises an exception if the unit is not unitless" do
        expect { 0.1.to_unit("m") }.to raise_error(ArgumentError, "Incompatible Units ('0.1' not compatible with 'm')")
        expect { 0.1.to_unit(RubyUnits::Unit.new("1 m")) }.to raise_error(ArgumentError, "Incompatible Units ('0.1' not compatible with '1 m')")
      end
    end
  end
end
