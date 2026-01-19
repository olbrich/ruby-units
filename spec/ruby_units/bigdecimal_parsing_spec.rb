# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Parsing with BigDecimal enabled" do
  around do |example|
    RubyUnits.reset
    RubyUnits.configure do |config|
      config.use_bigdecimal = true
    end
    example.run
    RubyUnits.reset
  end

  it "parses decimal strings into BigDecimal" do
    u = RubyUnits::Unit.new("0.1 m")
    expect(u.scalar).to be_a(BigDecimal)
    expect(u.scalar).to eq(BigDecimal("0.1"))
  end

  it "converts integral BigDecimal to Integer when appropriate" do
    expect(RubyUnits::Unit.new("1.0").scalar).to be(1)
  end

  it "parses scientific notation into BigDecimal" do
    u = RubyUnits::Unit.new("1e-1 m")
    expect(u.scalar).to be_a(BigDecimal)
    expect(u.scalar).to eq(BigDecimal("0.1"))
  end

  it "parses plain integers as Integer" do
    expect(RubyUnits::Unit.new("1 m").scalar).to be(Integer(1))
  end

  it "parses plain floats as BigDecimal" do
    u = RubyUnits::Unit.new("3.5 g")
    expect(u.scalar).to be_a(BigDecimal)
    expect(u.convert_to("mg").scalar).to eq(BigDecimal("3500"))
  end
end
