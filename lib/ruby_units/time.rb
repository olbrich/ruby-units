require 'time'

# Time math is handled slightly differently.  The difference is considered to be an exact duration if
# the subtracted value is in hours, minutes, or seconds.  It is rounded to the nearest day if the offset
# is in years, decades, or centuries.  This leads to less precise values, but ones that match the
# calendar better.
module RubyUnits
  module Time
    module ClassMethods
      # Convert a duration to a Time value by considering the duration to be the number of seconds since the
      # epoch
      # @param [::Time] args
      # @param [Integer] ms
      # @return [RubyUnits::Unit, Time]
      def at(*args)
        case args.first
        when RubyUnits::Unit
          secondary_unit = args[2] || 'microsecond'
          if args[1]
            super((args.first + RubyUnits::Unit.new(args[1], secondary_unit)).convert_to('s').scalar)
          else
            super(args.first.convert_to('s').scalar)
          end
        else
          super
        end
      end

      # @example
      #  Time.in '5 min'
      # @return (see Time#+)
      def in(duration)
        ::Time.now + duration.to_unit
      end
    end

    # @return (see RubyUnits::Unit#initialize)
    def to_unit(other = nil)
      other ? RubyUnits::Unit.new(self).convert_to(other) : RubyUnits::Unit.new(self)
    end

    # @param other [Time, RubyUnits::Unit]
    # @return [RubyUnits::Unit, Time]
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

    # @param other [Time, RubyUnits::Unit]
    # @return [RubyUnits::Unit, Time]
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

Time.prepend(RubyUnits::Time)
Time.singleton_class.prepend(RubyUnits::Time::ClassMethods)
