# frozen_string_literal: true

# Benchmark: Unit creation and operations
# Usage: ruby -I lib spec/benchmarks/unit_operations.rb
#
# Uses benchmark-ips to measure iterations/second for:
#   1. Unit creation from various string formats
#   2. Unit conversions
#   3. Arithmetic operations
#   4. Scaling with complexity

require "ruby-units"
require "benchmark/ips"

puts "Ruby #{RUBY_VERSION} | ruby-units #{RubyUnits::Unit::VERSION}"
puts "Definitions: #{RubyUnits::Unit.definitions.size} | Unit map entries: #{RubyUnits::Unit.unit_map.size}"
puts

# ── 1. Unit Creation (String Parsing) ──────────────────────────────────────────
puts "=" * 70
puts "1. UNIT CREATION FROM STRINGS"
puts "=" * 70

# Clear the cache so we measure real parsing cost
RubyUnits::Unit.clear_cache

Benchmark.ips do |x|
  x.config(warmup: 2, time: 5)

  x.report("simple: '1 m'") do
    RubyUnits::Unit.clear_cache
    Unit.new("1 m")
  end

  x.report("prefixed: '1 km'") do
    RubyUnits::Unit.clear_cache
    Unit.new("1 km")
  end

  x.report("compound: '1 kg*m/s^2'") do
    RubyUnits::Unit.clear_cache
    Unit.new("1 kg*m/s^2")
  end

  x.report("scientific: '1.5e-3 mm'") do
    RubyUnits::Unit.clear_cache
    Unit.new("1.5e-3 mm")
  end

  x.report("rational: '1/2 cup'") do
    RubyUnits::Unit.clear_cache
    Unit.new("1/2 cup")
  end

  x.report("feet-inch: \"6'4\\\"\"") do
    RubyUnits::Unit.clear_cache
    Unit.new("6'4\"")
  end

  x.report("lbs-oz: '8 lbs 8 oz'") do
    RubyUnits::Unit.clear_cache
    Unit.new("8 lbs 8 oz")
  end

  x.report("temperature: '37 degC'") do
    RubyUnits::Unit.clear_cache
    Unit.new("37 degC")
  end

  x.compare!
end

# ── 2. Unit Creation WITH Cache ────────────────────────────────────────────────
puts
puts "=" * 70
puts "2. UNIT CREATION WITH CACHE (repeated same unit)"
puts "=" * 70

Unit.new("1 m") # prime the cache

Benchmark.ips do |x|
  x.config(warmup: 2, time: 5)

  x.report("cached: '1 m'") { Unit.new("1 m") }
  x.report("cached: '5 kg*m/s^2'") { Unit.new("5 kg*m/s^2") }
  x.report("numeric: Unit.new(1)") { Unit.new(1) }
  x.report("hash: {scalar:1, ...}") do
    Unit.new(scalar: 1, numerator: ["<meter>"], denominator: ["<1>"])
  end

  x.compare!
end

# ── 3. Conversions ─────────────────────────────────────────────────────────────
puts
puts "=" * 70
puts "3. UNIT CONVERSIONS"
puts "=" * 70

meter = Unit.new("1 m")
km = Unit.new("1 km")
mph = Unit.new("60 mph")
degc = Unit.new("100 degC")

Benchmark.ips do |x|
  x.config(warmup: 2, time: 5)

  x.report("m -> km") { meter.convert_to("km") }
  x.report("km -> m") { km.convert_to("m") }
  x.report("mph -> m/s") { mph.convert_to("m/s") }
  x.report("degC -> degF") { degc.convert_to("degF") }
  x.report("to_base (km)") { km.to_base }

  x.compare!
end

# ── 4. Arithmetic ─────────────────────────────────────────────────────────────
puts
puts "=" * 70
puts "4. ARITHMETIC OPERATIONS"
puts "=" * 70

a = Unit.new("5 m")
b = Unit.new("3 m")
c = Unit.new("2 kg")
d = Unit.new("10 s")

Benchmark.ips do |x|
  x.config(warmup: 2, time: 5)

  x.report("addition: 5m + 3m") { a + b }
  x.report("subtraction: 5m - 3m") { a - b }
  x.report("multiply: 5m * 2kg") { a * c }
  x.report("divide: 5m / 10s") { a / d }
  x.report("power: (5m) ** 2") { a**2 }
  x.report("scalar multiply: 5m * 3") { a * 3 }

  x.compare!
end

# ── 5. Complexity Scaling ──────────────────────────────────────────────────────
puts
puts "=" * 70
puts "5. COMPLEXITY SCALING (uncached parsing)"
puts "=" * 70

# Various levels of unit string complexity
simple_units = %w[m kg s ampere degK mol candela]
medium_units = %w[km kPa MHz mA degC lbs gal]
complex_units = [
  "kg*m/s^2",
  "kg*m^2/s^2",
  "kg*m^2/s^3",
  "kg*m*s^-2",
  "kg*m^2*s^-3*A^-2"
]
very_complex_units = [
  "kg*m^2*s^-3*A^-2",
  "kg*m^2*s^-2*degK^-1*mol^-1",
  "kg^2*m^3*s^-4*A^-2",
  "kg*m^2*s^-3*A^-1",
  "kg^-1*m^-3*s^4*A^2"
]

Benchmark.ips do |x|
  x.config(warmup: 2, time: 5)

  x.report("simple (m, kg, s)") do
    RubyUnits::Unit.clear_cache
    simple_units.each { Unit.new("1 #{_1}") }
  end

  x.report("medium (km, kPa, MHz)") do
    RubyUnits::Unit.clear_cache
    medium_units.each { Unit.new("1 #{_1}") }
  end

  x.report("complex (kg*m/s^2)") do
    RubyUnits::Unit.clear_cache
    complex_units.each { Unit.new("1 #{_1}") }
  end

  x.report("very complex") do
    RubyUnits::Unit.clear_cache
    very_complex_units.each { Unit.new("1 #{_1}") }
  end

  x.compare!
end
