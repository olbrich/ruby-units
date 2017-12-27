require 'parslet'
require_relative '../transformers/standard'

module RubyUnits
  module Parsers
    # This parser is designed to handle SI and Imperial unit systems.  It will
    # also detect and properly parse several irregular unit forms (like '6 foot
    # 4' and '19 lbs, 4 oz').
    class Standard < ::Parslet::Parser
      # Checks for all defined unit names (excluding prefixes). The names are
      # sorted longest first and checked in that order so more specific ones
      # will be honored first.
      # @return [Parslet::Parser]
      def unit_names
        @unit_names ||= begin
          definitions = RubyUnits::Unit.definitions.values.reject(&:prefix?)
          names = definitions.map(&:aliases).flatten.sort_by { |unit_name| [unit_name.length, unit_name] }.reverse
          names.map { |name| str(name) }.reduce(:|)
        end
      end

      # Checks agains a list of all defined prefixes. Prefixes are sorted longest
      # first so that the most specific ones are honored first.
      # @return [Parslet::Parser]
      def prefixes
        @prefixes ||= begin
          definitions = RubyUnits::Unit.definitions.values.select(&:prefix?)
          names = definitions.map(&:aliases).flatten.sort_by { |unit_name| [unit_name.length, unit_name] }.reverse
          names.map { |name| str(name) }.reduce(:|)
        end
      end

      rule(:complex) { ((rational | decimal | integer).as(:real) >> (rational | decimal | integer).as(:imaginary) >> str('i')).as(:complex) }
      rule(:decimal) { ((integer_with_separators | (sign? >> unsigned_integer)) >> str('.') >> digits).as(:decimal) }
      rule(:digit) { match['0-9'] }
      rule(:digits?) { digits.maybe }
      rule(:digits) { digit.repeat(1) }
      rule(:div_operator) { space? >> str('/') >> space? }
      rule(:feet_inches) { (rational | decimal | integer).as(:ft) >> space? >> (str('feet') | str('foot') | str('ft') | str('"')) >> str(',').maybe >> space? >> (rational | decimal | integer).as(:in) >> space? >> (str('inches') | str('inch') | str('in') | str("'")).maybe }
      rule(:integer_with_separators) { (sign? >> non_zero_digit >> digit.repeat(0, 2) >> (separators >> digit.repeat(3, 3)).repeat(1)).as(:integer_with_separators) }
      rule(:integer) { (sign? >> unsigned_integer).as(:integer) }
      rule(:irregular_forms) { feet_inches.maybe | lbs_oz.maybe | stone.maybe }
      rule(:lbs_oz) { (rational | decimal | integer).as(:lbs) >> space? >> (str('pounds') | str('pound') | str('lbs') | str('lb')) >> str(',').maybe >> space? >> (rational | decimal | integer).as(:oz) >> space? >> (str('ounces') | str('ounce') | str('oz')) }
      rule(:mixed_fraction) { (integer.as(:whole) >> (space | str('-')) >> rational.as(:fraction)).as(:mixed_fraction) }
      rule(:mult_operator) { ((space? >> str('*') >> space?) | (space? >> str('x') >> space?) | space).as(:multiply) }
      rule(:non_zero_digit) { match['1-9'] }
      rule(:operator) { (div_operator | mult_operator).as(:operator) }
      rule(:power) { str('^') | str('**') }
      rule(:prefix?) { prefix.maybe }
      rule(:prefix) { unit_part.absent? >> prefixes.as(:prefix) }
      rule(:rational) { ((decimal | integer).as(:numerator) >> str('/') >> (decimal | integer).as(:denominator)).as(:rational) }
      rule(:scalar?) { scalar.maybe }
      rule(:scalar) { (mixed_fraction | complex | rational | scientific | decimal | integer_with_separators | integer).as(:scalar) }
      rule(:scientific) { ((decimal | integer).as(:mantissa) >> match['eE'] >> (sign? >> digits).as(:exponent)).as(:scientific) }
      rule(:separators) { match[',_'] }
      rule(:sign?) { sign.maybe }
      rule(:sign) { str('+') | str('-') }
      rule(:space?) { space.maybe }
      rule(:space) { str(' ') }
      rule(:stone) { (rational | decimal | integer).as(:stone) >> space? >> (str('stones') | str('stone') | str('st')) >> str(',').maybe >> space? >> (rational | decimal | integer).as(:lbs) >> space? >> (str('pounds') | str('pound') | str('lbs') | str('lb')).maybe }
      rule(:unit_atom) { (scalar? >> space? >> prefix? >> unit_part >> (power >> (rational | decimal | integer).as(:power)).maybe).as(:unit) }
      rule(:unit_part) { unit_names.as(:name) >> match['\w'].absent? }
      rule(:unit) { irregular_forms | infix_expression(unit_atom, [operator, 1, :left]) }
      rule(:unsigned_integer) { zero | non_zero_digit >> digits? | integer_with_separators }
      rule(:zero) { str('0') }

      root(:unit)
    end
  end
end
