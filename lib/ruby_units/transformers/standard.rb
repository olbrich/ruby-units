module RubyUnits
  module Transformers
    # Transform the parsed syntax tree into appropriate numbers and
    # {RubyUnits::Unit} objects.
    class Standard < Parslet::Transform
      rule(integer: simple(:value)) { Integer(value.to_s.delete(',_')) }
      rule(decimal: simple(:value)) { Float(value.to_s.delete(',_')) }
      rule(scientific: { mantissa: simple(:mantissa), exponent: simple(:exponent) }) { Float(mantissa) * 10**Float(exponent) }
      rule(rational: { numerator: simple(:numerator), denominator: simple(:denominator) }) { Rational(numerator.to_s.delete(',_'), denominator.to_s.delete(',_')) }
      rule(mixed_fraction: { whole: simple(:whole), fraction: simple(:fraction) }) { (whole <=> 0) * (whole.abs + fraction) }
      rule(complex: { real: simple(:real), imaginary: simple(:imaginary) }) { Complex(real, imaginary) }

      rule(ft: simple(:feet), in: simple(:inches)) { RubyUnits::Unit.new(feet, 'ft') + RubyUnits::Unit.new(inches, 'in') }
      rule(lbs: simple(:lbs), oz: simple(:oz)) { RubyUnits::Unit.new(lbs, 'lbs') + RubyUnits::Unit.new(oz, 'oz') }
      rule(hours: simple(:hours), minutes: simple(:minutes)) { RubyUnits::Unit.new(hours.to_i, 'h') + RubyUnits::Unit.new(minutes.to_i, 'min') }
      rule(hours: simple(:hours), minutes: simple(:minutes), seconds: simple(:seconds)) { RubyUnits::Unit.new(hours.to_i, 'h') + RubyUnits::Unit.new(minutes.to_i, 'min') + RubyUnits::Unit.new(seconds.to_i, 'sec') }
      rule(hours: simple(:hours), minutes: simple(:minutes), seconds: simple(:seconds), microseconds: simple(:microseconds)) { RubyUnits::Unit.new(hours.to_i, 'h') + RubyUnits::Unit.new(minutes.to_i, 'min') + RubyUnits::Unit.new(seconds.to_i, 'sec') + RubyUnits::Unit.new(microseconds.to_i, 'usec') }

      rule(stone: simple(:stone), lbs: simple(:lbs)) { RubyUnits::Unit.new(stone, 'stone') + RubyUnits::Unit.new(lbs, 'lbs') }

      rule(unit: { scalar: simple(:scalar), prefix: simple(:prefix), name: simple(:name), power: simple(:power) }) do
        scalar * RubyUnits::Unit.new(prefix: prefix.to_s, name: name.to_s)**power
      end

      rule(unit: { scalar: simple(:scalar), name: simple(:name), power: simple(:power) }) do
        scalar * RubyUnits::Unit.new(name: name.to_s)**power
      end

      rule(unit: { scalar: simple(:scalar), prefix: simple(:prefix), name: simple(:name) }) do
        RubyUnits::Unit.new(scalar: scalar, prefix: prefix.to_s, name: name.to_s)
      end

      rule(unit: { scalar: simple(:scalar), prefix: simple(:prefix) }) do
        RubyUnits::Unit.new(scalar: scalar, prefix: prefix.to_s)
      end

      rule(unit: { scalar: simple(:scalar), name: simple(:name) }) do
        RubyUnits::Unit.new(scalar: scalar, name: name.to_s)
      end

      rule(unit: { prefix: simple(:prefix), name: simple(:name), power: simple(:power) }) do
        RubyUnits::Unit.new(prefix: prefix.to_s, name: name.to_s)**power
      end

      rule(unit: { prefix: simple(:prefix), name: simple(:name) }) do
        RubyUnits::Unit.new(prefix: prefix.to_s, name: name.to_s)
      end

      rule(unit: { name: simple(:name), power: simple(:power) }) do
        RubyUnits::Unit.new(name: name.to_s)**power
      end

      rule(unit: { scalar: simple(:scalar), power: simple(:power) }) do
        RubyUnits::Unit.new(scalar: scalar)**power
      end

      rule(unit: { name: simple(:name) }) do
        RubyUnits::Unit.new(name: name.to_s)
      end

      rule(unit: { scalar: simple(:scalar) }) do
        RubyUnits::Unit.new(scalar: scalar)
      end

      rule(unit: simple(:unit)) do
        RubyUnits::Unit.new(1)
      end

      rule(multiply: simple(:value)) { '*' }
      rule(operator: simple(:operator)) { operator.to_sym }
      rule(l: simple(:l), o: simple(:o), r: simple(:r)) { l.public_send(o, r) }
    end
  end
end
