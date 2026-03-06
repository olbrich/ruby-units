# frozen_string_literal: true

require File.dirname(__FILE__) + "/../spec_helper"

describe "Github issue #49" do
  let(:a) { RubyUnits::Unit.new("3 cm^3") }
  let(:b) { RubyUnits::Unit.new(a) }

  it "subtracts a unit properly from one initialized with a unit" do
    expect(b - RubyUnits::Unit.new("1.5 cm^3")).to eq(RubyUnits::Unit.new("1.5 cm^3"))
  end
end

describe "normalize_to_i preserves Float scalar type" do
  it "preserves Float when constructing with a numeric scalar" do
    unit = RubyUnits::Unit.new(400.0, "m^2")
    expect(unit.scalar).to be_a(Float)
    expect(unit.scalar).to eq(400.0)
  end

  it "preserves Float when multiplying a unit by a Float" do
    unit = RubyUnits::Unit.new("m^2") * 400.0
    expect(unit.scalar).to be_a(Float)
    expect(unit.scalar).to eq(400.0)
  end

  it "does not break Float division semantics on extracted scalars" do
    a = RubyUnits::Unit.new("m^2") * 400.0
    b = RubyUnits::Unit.new("m^2") * 1000.0
    expect(a.scalar / b.scalar).to eq(0.4)
  end

  it "normalizes whole Rationals to Integer" do
    unit = RubyUnits::Unit.new(Rational(400, 1), "m^2")
    expect(unit.scalar).to be_a(Integer)
    expect(unit.scalar).to eq(400)
  end

  it "preserves non-whole Rationals" do
    unit = RubyUnits::Unit.new(Rational(3, 2), "m")
    expect(unit.scalar).to be_a(Rational)
    expect(unit.scalar).to eq(Rational(3, 2))
  end
end

describe "Unit.new(numeric, unit_object) — Unit as second argument" do
  it "creates a unit with the given scalar and the Unit's unit" do
    du = RubyUnits::Unit.new("1 m^2")
    result = RubyUnits::Unit.new(9.290304, du)
    expect(result.units).to eq("m^2")
    expect(result.scalar).to be_within(1e-6).of(9.290304)
  end

  it "works with integer scalar and simple unit" do
    du = RubyUnits::Unit.new("1 kg")
    result = RubyUnits::Unit.new(5, du)
    expect(result).to eq(RubyUnits::Unit.new("5 kg"))
  end

  it "works when the Unit has a non-1 scalar" do
    du = RubyUnits::Unit.new("2 m")
    result = RubyUnits::Unit.new(3, du)
    expect(result).to eq(RubyUnits::Unit.new("6 m"))
  end
end

describe "Unit aliases containing spaces" do
  it "parses a unit alias with a space" do
    # "square meter" is a standard alias for m^2 if defined
    # First verify the alias is in the unit_map
    if RubyUnits::Unit.unit_map.key?("square meter")
      result = RubyUnits::Unit.new("1 square meter")
      expect(result).to be_compatible_with(RubyUnits::Unit.new("1 m^2"))
    else
      # Define it for the test
      RubyUnits::Unit.define("m2_test") do |u|
        u.definition = RubyUnits::Unit.new("1 m^2")
        u.aliases = ["square meter test"]
      end
      result = RubyUnits::Unit.new("1 square meter test")
      expect(result).to eq(RubyUnits::Unit.new("1 m^2"))
    end
  end

  it "parses 'short ton' when registered as an alias" do
    if RubyUnits::Unit.unit_map.key?("short ton")
      result = RubyUnits::Unit.new("1 short ton")
      expect(result.scalar).to eq(1)
    else
      skip "short ton alias not registered"
    end
  end
end
