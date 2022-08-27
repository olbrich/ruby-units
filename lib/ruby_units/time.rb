require 'time'

module RubyUnits
  # Time math is handled slightly differently.  The difference is considered to be an exact duration if
  # the subtracted value is in hours, minutes, or seconds.  It is rounded to the nearest day if the offset
  # is in years, decades, or centuries.  This leads to less precise values, but ones that match the
  # calendar better.
  module Time
    # Class methods for [Time] objects
    module ClassMethods
      # Convert a duration to a [::Time] object by considering the duration to be
      # the number of seconds since the epoch
      #
      # @param [Array<RubyUnits::Unit, Numeric, Symbol, Hash>] args
      # @return [::Time]
      def at(*args, **kwargs)
        case args.first
        when RubyUnits::Unit
          options = args.last.is_a?(Hash) ? args.pop : kwargs
          secondary_unit = args[2] || 'microsecond'
          case args[1]
          when Numeric
            super((args.first + RubyUnits::Unit.new(args[1], secondary_unit.to_s)).convert_to('second').scalar, **options)
          else
            super(args.first.convert_to('second').scalar, **options)
          end
        else
          super(*args, **kwargs)
        end
      end

      # @example
      #  Time.in '5 min'
      # @param duration [#to_unit]
      # @return [::Time]
      def in(duration)
        ::Time.now + duration.to_unit
      end
    end

    # Convert a [::Time] object to a [RubyUnits::Unit] object. The time is
    # considered to be a duration with the number of seconds since the epoch.
    #
    # @param other [String, RubyUnits::Unit]
    # @return [RubyUnits::Unit]
    def to_unit(other = nil)
      other ? RubyUnits::Unit.new(self).convert_to(other) : RubyUnits::Unit.new(self)
    end

    # @param other [::Time, RubyUnits::Unit]
    # @return [RubyUnits::Unit, ::Time]
    def +(other)
      case other
      when RubyUnits::Unit
        other = other.convert_to('d').round.convert_to('s') if %w[y decade century].include? other.units
        begin
          super(other.convert_to('s').scalar)
        rescue RangeError
          to_datetime + other
        end
      else
        super
      end
    end

    # @param other [::Time, RubyUnits::Unit]
    # @return [RubyUnits::Unit, ::Time]
    def -(other)
      case other
      when RubyUnits::Unit
        other = other.convert_to('d').round.convert_to('s') if %w[y decade century].include? other.units
        begin
          super(other.convert_to('s').scalar)
        rescue RangeError
          public_send(:to_datetime) - other
        end
      else
        super
      end
    end
  end
end

# @note Do this instead of Time.prepend(RubyUnits::Time) to avoid YARD warnings
# @see https://github.com/lsegal/yard/issues/1353
class Time
  prepend(RubyUnits::Time)
  singleton_class.prepend(RubyUnits::Time::ClassMethods)
end
