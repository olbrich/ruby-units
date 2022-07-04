require 'time'

module RubyUnits
  # Extra methods for converting [String] objects to [RubyUnits::Unit] objects
  # and using string formatting with Units.
  module String
    # Make a string into a unit
    #
    # @param other [RubyUnits::Unit, String] unit to convert to
    # @return [RubyUnits::Unit]
    def to_unit(other = nil)
      other ? RubyUnits::Unit.new(self).convert_to(other) : RubyUnits::Unit.new(self)
    end

    # Format unit output using formatting codes
    # @example '%0.2f' % '1 mm'.to_unit => '1.00 mm'
    #
    # @param other [RubyUnits::Unit, Object]
    # @return [String]
    def %(*other)
      if other.first.is_a?(RubyUnits::Unit)
        other.first.to_s(self)
      else
        super
      end
    end

    # @param (see RubyUnits::Unit#convert_to)
    # @return (see RubyUnits::Unit#convert_to)
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
