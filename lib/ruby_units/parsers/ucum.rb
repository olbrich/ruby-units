require 'parslet'
module RubyUnits
  module Parsers
    class UCUM < ::Parslet::Parser

      UNITS = %w[g m s]
      UPCASE_UNITS = %w[G M S]
      PREFIXES = %w[M k h da d c m u n]
      UPCASE_PREFIXES = %w[MA K H DA D C M U N]
      rule(:annotation) { str('{') >> match['[:alpha:]'].repeat(1).as(:annotation) >> str('}') }
      rule(:complex) { ((rational | decimal | integer).as(:real) >> (rational | decimal | integer).as(:imaginary) >> str('i')).as(:complex) }
      rule(:decimal) { (integer >> str('.') >> digits).as(:decimal) }
      rule(:digit) { match['0-9'] }
      rule(:digits?) { digits.maybe }
      rule(:digits) { digit.repeat(1) }
      rule(:div_operator) { str('/') }
      rule(:integer) { (sign? >> unsigned_integer).as(:integer) }
      rule(:integer?) { integer.maybe }
      rule(:mult_operator) { str('.') }
      rule(:non_zero_digit) { match['1-9'] }
      rule(:operator) { (div_operator | mult_operator).as(:operator) }
      rule(:prefix?) { prefix.maybe }
      # prefix needs to dynamically determine which prefix names to search for
      rule(:prefix) { unit_part.absent? >> (PREFIXES.map {|p| str(p)}.reduce(:|)).as(:prefix) }
      rule(:prefix_upcase) { unit_part_upcase.absent? >> (UPCASE_PREFIXES.map {|p| str(p)}.reduce(:|)).as(:prefix) }
      rule(:prefix_upcase?) { prefix_upcase.maybe }
      rule(:rational) { ((decimal | integer).as(:numerator) >> str('/') >> (decimal | integer).as(:denominator)).as(:rational) }
      rule(:scalar?) { scalar.maybe }
      rule(:scalar) { ( exponent | complex | rational | scientific | decimal | integer).as(:scalar) }
      rule(:scientific) { ((decimal | integer).as(:mantissa) >> match['eE'] >> (sign? >> digits).as(:exponent)).as(:scientific) }
      rule(:sign?) { sign.maybe }
      rule(:sign) { str('+') | str('-') }
      rule(:space?) { space.maybe }
      rule(:space) { str(' ') }
      rule(:exponent) { str('10*') >> integer.as(:power) }
      rule(:exponent?) { exponent.maybe }
      rule(:power) { str('10*').maybe >> integer.as(:power) }
      rule(:power?) { power.maybe }
      rule(:unit_atom) { (scalar? >> space? >> (prefix? | prefix_upcase?) >> (unit_part? | unit_part_upcase?) >> power?).as(:unit) }
      # unit_part needs to dynamically determine which unit names to search for
      rule(:unit_part) { (UNITS.map { |u| str(u) }.reduce(:|)).as(:name)  }
      rule(:unit_part?) { unit_part.maybe }
      rule(:unit_part_upcase) { (UPCASE_UNITS.map { |u| str(u) }.reduce(:|)).as(:name) }
      rule(:unit_part_upcase?) { unit_part_upcase.maybe }
      rule(:unit) { any.present? >> infix_expression(unit_atom, [operator, 1, :left]) }
      rule(:unsigned_integer) { zero | non_zero_digit >> digits? }
      rule(:zero) { str('0') }

      root(:unit)
    end
  end
end
