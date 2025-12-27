# frozen_string_literal: true

require "time"

module RubyUnits
  # Time math is handled slightly differently.  The difference is considered to be an exact duration if
  # the subtracted value is in hours, minutes, or seconds.  It is rounded to the nearest day if the offset
  # is in years, decades, or centuries.  This leads to less precise values, but ones that match the
  # calendar better.
  module Time
    # Class methods for [::Time] objects
    module ClassMethods
      # Convert a duration to a [::Time] object by considering the duration to be
      # the number of seconds since the epoch.
      #
      # @example Create time from a Unit duration
      #   Time.at(Unit.new("5 min"))  #=> Time object 300 seconds after epoch
      #
      # @example Create time from Unit with offset
      #   Time.at(Unit.new("1 h"), 500, :millisecond)  #=> Time 1 hour + 500 ms after epoch
      #
      # @param [Array<RubyUnits::Unit, Numeric, Symbol, Hash>] args Arguments passed to Time.at
      # @return [::Time] A Time object at that many seconds since epoch
      def at(*args, **)
        first_arg = args.first
        return super unless first_arg.is_a?(RubyUnits::Unit)

        time_in_seconds = calculate_time_in_seconds(first_arg, args[1], args[2])
        remaining_args = build_remaining_args(args)

        super(time_in_seconds, *remaining_args, **)
      end

      # Calculate a future time by adding a duration to the current time.
      # This is a convenience method equivalent to Time.now + duration.
      #
      # @example Get time 5 minutes from now
      #   Time.in('5 min')  #=> Time object 5 minutes in the future
      #
      # @example Using various duration formats
      #   Time.in('2 hours')  #=> 2 hours from now
      #   Time.in(Unit.new('30 sec'))  #=> 30 seconds from now
      #
      # @param duration [String, RubyUnits::Unit, #to_unit] A duration that can be converted to a Unit
      # @return [::Time] A Time object representing the current time plus the duration
      # :reek:UtilityFunction - This is a class method convenience wrapper, state independence is by design
      def in(duration)
        ::Time.now + duration.to_unit
      end

      private

      # Calculate the time in seconds from a Unit and optional offset
      # @param base_unit [RubyUnits::Unit] The base time unit
      # @param offset_value [Numeric, nil] Optional offset value
      # @param offset_unit [String, Symbol, nil] Unit for the offset (default: "microsecond")
      # @return [Numeric] Time in seconds
      # :reek:UtilityFunction - Private helper method, state independence is acceptable
      # :reek:ControlParameter - Default parameter handling is appropriate here
      def calculate_time_in_seconds(base_unit, offset_value, offset_unit)
        return base_unit.convert_to("second").scalar unless offset_value.is_a?(Numeric)

        unit_str = offset_unit&.to_s || "microsecond"
        (base_unit + RubyUnits::Unit.new(offset_value, unit_str)).convert_to("second").scalar
      end

      # Build remaining arguments to pass to super, skipping the first 3 processed args
      # @param args [Array] Original arguments array
      # @return [Array] Remaining arguments after the first three
      # :reek:UtilityFunction - Private helper method, state independence is acceptable
      def build_remaining_args(args)
        args[3..] || []
      end
    end

    # Convert a [::Time] object to a [RubyUnits::Unit] object representing
    # the duration in seconds since the Unix epoch (January 1, 1970 00:00:00 UTC).
    #
    # @example Convert time to unit
    #   Time.now.to_unit  #=> Unit representing seconds since epoch
    #
    # @example Convert time to specific unit
    #   Time.now.to_unit('hour')  #=> Unit in hours since epoch
    #
    # @param other [String, RubyUnits::Unit, nil] Optional target unit for conversion
    # @return [RubyUnits::Unit] A Unit object representing the seconds since epoch
    def to_unit(other = nil)
      unit = RubyUnits::Unit.new(self)
      other ? unit.convert_to(other) : unit
    end

    # Add a duration to a time. For large units (years, decades, centuries),
    # the duration is first converted to days and rounded to handle calendar complexities.
    # If the result would be out of range for Time, falls back to DateTime.
    #
    # @example Add hours to time
    #   Time.now + Unit.new('2 hours')  #=> Time 2 hours in future
    #
    # @example Add years (rounded to days)
    #   Time.now + Unit.new('1 year')  #=> Time ~365 days in future
    #
    # @param other [::Time, RubyUnits::Unit, Numeric] Value to add
    # @return [::Time, DateTime] The resulting time, or DateTime if out of Time range
    def +(other)
      return super unless other.is_a?(RubyUnits::Unit)

      duration_in_seconds = convert_to_seconds(other)
      super(duration_in_seconds)
    rescue RangeError
      to_datetime + other
    end

    # Subtract a duration from a time. For large units (years, decades, centuries),
    # the duration is first converted to days and rounded to handle calendar complexities.
    # If the result would be out of range for Time, falls back to DateTime.
    #
    # @example Subtract hours from time
    #   Time.now - Unit.new('2 hours')  #=> Time 2 hours in past
    #
    # @example Subtract years (rounded to days)
    #   Time.now - Unit.new('1 year')  #=> Time ~365 days in past
    #
    # @param other [::Time, RubyUnits::Unit, Numeric] Value to subtract
    # @return [::Time, DateTime, Numeric] The resulting time (DateTime if out of range),
    #   or numeric difference in seconds if subtracting another Time
    def -(other)
      return super unless other.is_a?(RubyUnits::Unit)

      duration_in_seconds = convert_to_seconds(other)
      super(duration_in_seconds)
    rescue RangeError
      public_send(:to_datetime) - other
    end

    private

    # Convert a unit to seconds, rounding large time units (years, decades, centuries) to days first.
    # This handles calendar complexities where years don't have a fixed number of seconds.
    #
    # @param unit [RubyUnits::Unit] The duration unit to convert
    # @return [Numeric] The duration in seconds
    # :reek:UtilityFunction - Private helper method, state independence is acceptable
    def convert_to_seconds(unit)
      normalized_unit = if %w[y decade century].include?(unit.units)
                          unit.convert_to("d").round.convert_to("s")
                        else
                          unit.convert_to("s")
                        end
      normalized_unit.scalar
    end
  end
end

# @note Do this instead of Time.prepend(RubyUnits::Time) to avoid YARD warnings
# @see https://github.com/lsegal/yard/issues/1353
class Time
  prepend(RubyUnits::Time)
  singleton_class.prepend(RubyUnits::Time::ClassMethods)
end
