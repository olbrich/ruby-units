# frozen_string_literal: true

require "time"

module RubyUnits
  # Extra methods for converting [String] objects to [RubyUnits::Unit] objects
  # and using string formatting with Units.
  #
  # These extensions allow strings to be easily converted to Unit objects and
  # provide Ruby's standard formatting operators for working with units.
  module String
    # Converts a string into a Unit object
    #
    # Parses the string as a unit specification and optionally converts it to
    # another unit. The string should follow the standard unit format (e.g., "1 mm",
    # "5 kg/s", "10 degC").
    #
    # @example Create a simple unit
    #   "1 mm".to_unit #=> #<Unit:0x... @scalar=1, @numerator=["<meter>"], ...>
    # @example Create and convert a unit
    #   "1 mm".to_unit('cm') #=> #<Unit:0x... @scalar=0.1, @numerator=["<meter>"], ...>
    # @example Parse a complex unit
    #   "5 kg*m/s^2".to_unit #=> #<Unit:0x... @scalar=5, ...>
    #
    # @param other [RubyUnits::Unit, String, nil] optional unit to convert to after parsing
    # @return [RubyUnits::Unit] the parsed (and optionally converted) unit
    def to_unit(other = nil)
      other ? RubyUnits::Unit.new(self).convert_to(other) : RubyUnits::Unit.new(self)
    end

    # Format unit output using formatting codes
    #
    # Allows Ruby's string formatting syntax to work with units. When the argument
    # is a Unit, it will format the unit using this string as a format template.
    # Otherwise, it falls back to the standard String#% behavior.
    #
    # @example Format a unit with precision
    #   '%0.2f' % '1 mm'.to_unit #=> '1.00 mm'
    # @example Format and convert a unit
    #   '%0.2f in' % '1 mm'.to_unit #=> '0.04 in'
    # @example Standard string formatting (non-unit)
    #   'Hello %s' % ['World'] #=> 'Hello World'
    #
    # @param other [RubyUnits::Unit, Object] the unit to format, or other objects for standard formatting
    # @return [String] the formatted string
    def %(*other)
      first_arg = other.first
      if first_arg.is_a?(RubyUnits::Unit)
        first_arg.to_s(self)
      else
        super
      end
    end

    # Converts the string to a Unit and then converts it to another unit
    #
    # This is a convenience method that combines parsing and conversion into a single
    # operation. It's equivalent to calling `to_unit.convert_to(other)`.
    #
    # @example Convert millimeters to centimeters
    #   "10 mm".convert_to('cm') #=> #<Unit:0x... @scalar=1.0, @numerator=["<meter>"], ...>
    # @example Convert between compound units
    #   "100 km/h".convert_to('m/s') #=> #<Unit:0x... @scalar=27.77..., ...>
    #
    # @param other [RubyUnits::Unit, String] the target unit to convert to
    # @return [RubyUnits::Unit] the converted unit
    # @raise [ArgumentError] if the units are incompatible for conversion
    def convert_to(other)
      to_unit.convert_to(other)
    end
  end
end

# @note Do this instead of String.prepend(RubyUnits::String) to avoid YARD warnings
# @see https://github.com/lsegal/yard/issues/1353
class String
  prepend(RubyUnits::String)
end
