module RubyUnits
  module Transformers
    class Metric < Parslet::Transform
      rule(integer: simple(:value)) { Integer(value) }
      rule(integer_with_separators: simple(:value)) { Integer(value.to_s.delete(',_')) }
      rule(decimal: simple(:value)) { Float(value) }
      rule(scientific: { mantissa: simple(:mantissa), exponent: simple(:exponent) }) { Float(mantissa) * 10**Float(exponent) }
      rule(rational: { numerator: simple(:numerator), denominator: simple(:denominator) }) { Rational(numerator, denominator) }
      rule(mixed_fraction: { whole: simple(:whole), fraction: simple(:fraction) }) { (whole <=> 0) * (whole.abs + fraction) }
      rule(complex: { real: simple(:real), imaginary: simple(:imaginary) }) { Complex(real, imaginary) }
      rule(ft: simple(:feet), in: simple(:inches)) { RubyUnits::Unit.new(feet, 'ft') + RubyUnits::Unit.new(inches, 'in') }
      rule(lbs: simple(:lbs), oz: simple(:oz)) { RubyUnits::Unit.new(lbs, 'lbs') + RubyUnits::Unit.new(oz, 'oz') }

      rule(unit: subtree(:unit)) { RubyUnits::Unit.new(unit.fetch(:scalar, 1), unit[:name].to_s)**unit.fetch(:power, 1) }
      rule(multiply: simple(:value)) { '*' }
      rule(operator: simple(:operator)) { operator.to_sym }
      rule(l: simple(:l), o: simple(:o), r: simple(:r)) { l.public_send(o, r) }
    end
  end
end
