require 'parslet'
module RubyUnits
  module Parsers
    class Metric < ::Parslet::Parser
      rule(:complex) { ((rational | decimal | integer).as(:real) >> (rational | decimal | integer).as(:imaginary) >> str('i')).as(:complex) }
      rule(:decimal) { (integer_with_separators | integer) >> str('.') >> digits.as(:decimal) }
      rule(:digit) { match['0-9'] }
      rule(:digits?) { digits.maybe }
      rule(:digits) { digit.repeat(1) }
      rule(:div_operator) { space? >> str('/') >> space? }
      rule(:integer_with_separators) { sign? >> non_zero_digit >> digit.repeat(0, 2) >> (separators >> digit.repeat(3, 3)).repeat(1) }
      rule(:integer) { sign? >> unsigned_integer.as(:integer) }
      rule(:mixed_fraction) { (integer.as(:whole) >> (space | str('-')) >> rational.as(:fraction)).as(:mixed_fraction) }
      rule(:mult_operator) { ((space? >> str('*') >> space?) | (space? >> str('x') >> space?) | space) }
      rule(:non_zero_digit) { match['1-9'] }
      rule(:operator) { (div_operator | mult_operator).as(:operator) }
      rule(:power) { str('^') | str('**') }
      rule(:prefix?) { prefix.maybe }
      # prefix needs to dynamically determine which prefix names to search for
      rule(:prefix) { unit_part.absent? >> match['m'].as(:prefix) }
      rule(:rational) { ((decimal | integer).as(:numerator) >> str('/') >> (decimal | integer).as(:denominator)).as(:rational) }
      rule(:scalar?) { scalar.maybe }
      rule(:scalar) { (mixed_fraction | complex | rational | scientific | decimal | integer).as(:scalar) }
      rule(:scientific) { ((decimal | integer).as(:mantissa) >> match['eE'] >> (sign? >> digits).as(:exponent)).as(:scientific) }
      rule(:separators) { match[',_'] }
      rule(:sign?) { sign.maybe }
      rule(:sign) { str('+') | str('-') }
      rule(:space?) { space.maybe }
      rule(:space) { str(' ') }
      rule(:unit_atom) { (scalar? >> space? >> prefix? >> unit_part >> (power >> (rational | decimal | integer).as(:power)).maybe).as(:unit) }
      # unit_part needs to dynamically determine which unit names to search for
      rule(:unit_part) { match['ms'].as(:name) >> match['\w'].absent? }
      rule(:unit) { infix_expression(unit_atom, [operator, 1, :left]) }
      rule(:unsigned_integer) { zero | non_zero_digit >> digits? | integer_with_separators }
      rule(:zero) { str('0') }

      root(:unit)
    end
  end
end
