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

      rule(unit: subtree(:unit)) do
        RubyUnits::Unit.new(scalar: unit.fetch(:scalar, 1), prefix: unit[:prefix].to_s, name: unit[:name].to_s)**unit.fetch(:power, 1)
      end
      rule(multiply: simple(:value)) { '*' }
      rule(operator: simple(:operator)) { operator.to_sym }
      rule(l: simple(:l), o: simple(:o), r: simple(:r)) { l.public_send(o, r) }
    end
  end
end
