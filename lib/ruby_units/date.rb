# frozen_string_literal: true

require "date"

module RubyUnits
  # Extra methods for [::Date] to allow it to be used as a [RubyUnits::Unit]
  module Date
    # Add a duration to a date. For large time units (years, decades, centuries),
    # the duration is first converted to days and rounded to maintain calendar accuracy.
    #
    # @example Add weeks to a date
    #   Date.today + Unit.new("1 week")  #=> Date 7 days in future
    #
    # @example Add months (converted to days)
    #   Date.new(2024, 1, 15) + Unit.new("1 month")  #=> Approximately 30 days later
    #
    # @example Add years (converted to days and rounded)
    #   Date.today + Unit.new("1 year")  #=> Approximately 365 days in future
    #
    # @param [RubyUnits::Unit, Object] other Duration to add or standard Ruby object for default behavior
    # @return [Date] A new Date object with the duration added
    def +(other)
      return super unless other.is_a?(RubyUnits::Unit)

      duration_in_days = convert_to_days(other)
      super(duration_in_days)
    end

    # Subtract a duration from a date. For large time units (years, decades, centuries),
    # the duration is first converted to days and rounded to maintain calendar accuracy.
    #
    # @example Subtract weeks from a date
    #   Date.today - Unit.new("1 week")  #=> Date 7 days in past
    #
    # @example Subtract months (converted to days)
    #   Date.new(2024, 3, 15) - Unit.new("1 month")  #=> Approximately 30 days earlier
    #
    # @example Subtract years (converted to days and rounded)
    #   Date.today - Unit.new("1 year")  #=> Approximately 365 days in past
    #
    # @param [RubyUnits::Unit, Object] other Duration to subtract or standard Ruby object for default behavior
    # @return [Date, Numeric] A new Date object with duration subtracted, or days between dates if both are Dates
    def -(other)
      return super unless other.is_a?(RubyUnits::Unit)

      duration_in_days = convert_to_days(other)
      super(duration_in_days)
    end

    # Convert a Date object to a Unit representing the number of days since the
    # start of the Julian calendar (Julian Day Number).
    #
    # @example Convert date to unit in days
    #   Date.today.to_unit  #=> Unit representing days since Julian calendar start
    #
    # @example Convert date to unit and change units
    #   Date.today.to_unit('week')  #=> Unit in weeks since Julian calendar start
    #   Date.today.to_unit('year')  #=> Unit in years since Julian calendar start
    #
    # @param other [RubyUnits::Unit, String, nil] Optional target unit for conversion
    # @return [RubyUnits::Unit] A Unit object representing the date as a duration
    def to_unit(other = nil)
      other ? RubyUnits::Unit.new(self).convert_to(other) : RubyUnits::Unit.new(self)
    end

    # @return [String]
    def inspect
      to_s
    end

    private

    # Convert a unit to days, rounding large time units (years, decades, centuries) to days first.
    # This handles calendar complexities where years don't have a fixed number of days.
    #
    # @param unit [RubyUnits::Unit] The duration unit to convert
    # @return [Numeric] The duration in days
    # :reek:UtilityFunction - Private helper method, state independence is acceptable
    def convert_to_days(unit)
      normalized_unit = if %w[y decade century].include?(unit.units)
                          unit.convert_to("d").round
                        else
                          unit.convert_to("day")
                        end
      normalized_unit.scalar
    end
  end
end

# @note Do this instead of Date.prepend(RubyUnits::Date) to avoid YARD warnings
# @see https://github.com/lsegal/yard/issues/1353
class Date
  prepend RubyUnits::Date
end
