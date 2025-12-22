# frozen_string_literal: true

require "date"

module RubyUnits
  # Extra methods for [::Date] to allow it to be used as a [RubyUnits::Unit]
  module Date
    # Allow date objects to do offsets by a time unit
    #
    # @example Date.today + Unit.new("1 week") => gives today+1 week
    # @param [RubyUnits::Unit, Object] other
    # @return [RubyUnits::Unit]
    def +(other)
      case other
      when RubyUnits::Unit
        other = other.convert_to("d").round if %w[y decade century].include? other.units
        super(other.convert_to("day").scalar)
      else
        super
      end
    end

    # Allow date objects to do offsets by a time unit
    #
    # @example Date.today - Unit.new("1 week") => gives today-1 week
    # @param [RubyUnits::Unit, Object] other
    # @return [RubyUnits::Unit]
    def -(other)
      case other
      when RubyUnits::Unit
        other = other.convert_to("d").round if %w[y decade century].include? other.units
        super(other.convert_to("day").scalar)
      else
        super
      end
    end

    # Construct a unit from a Date. This returns the number of days since the
    # start of the Julian calendar as a Unit.
    #
    # @example Date.today.to_unit => Unit
    # @return [RubyUnits::Unit]
    # @param other [RubyUnits::Unit, String] convert to same units as passed
    def to_unit(other = nil)
      other ? RubyUnits::Unit.new(self).convert_to(other) : RubyUnits::Unit.new(self)
    end

    # @deprecated The dump parameter is deprecated and will be removed in a future version.
    # @param dump [Boolean] if true, use default inspect; if false, use to_s (deprecated behavior)
    # @return [String]
    def inspect(dump = false)
      dump ? super : to_s
    end
  end
end

# @note Do this instead of Date.prepend(RubyUnits::Date) to avoid YARD warnings
# @see https://github.com/lsegal/yard/issues/1353
class Date
  prepend RubyUnits::Date
end
