require 'time'
#
# Time math is handled slightly differently.  The difference is considered to be an exact duration if
# the subtracted value is in hours, minutes, or seconds.  It is rounded to the nearest day if the offset
# is in years, decades, or centuries.  This leads to less precise values, but ones that match the
# calendar better.
class Time
  class << self
    alias unit_time_at at
  end

  # Convert a duration to a Time value by considering the duration to be the number of seconds since the
  # epoch
  # @param [Time] arg
  # @param [Integer] ms
  # @return [RubyUnits::Unit, Time]
  def self.at(arg, ms = nil)
    case arg
    when Time
      unit_time_at(arg)
    when RubyUnits::Unit
      if ms
        unit_time_at(arg.convert_to('s').scalar, ms)
      else
        unit_time_at(arg.convert_to('s').scalar)
      end
    else
      ms.nil? ? unit_time_at(arg) : unit_time_at(arg, ms)
    end
  end

  # @return (see RubyUnits::Unit#initialize)
  def to_unit(other = nil)
    other ? RubyUnits::Unit.new(self).convert_to(other) : RubyUnits::Unit.new(self)
  end

  unless Time.public_method_defined?(:to_date)
    # :nocov_19:
    public :to_date
    # :nocov_19:
  end

  alias unit_add +
  # @return [RubyUnits::Unit, Time]
  def +(other)
    case other
    when RubyUnits::Unit
      other = other.convert_to('d').round.convert_to('s') if %w[y decade century].include? other.units
      begin
        unit_add(other.convert_to('s').scalar)
      rescue RangeError
        to_datetime + other
      end
    else
      unit_add(other)
    end
  end

  # @example
  #  Time.in '5 min'
  # @return (see Time#+)
  def self.in(duration)
    Time.now + duration.to_unit
  end

  alias unit_sub -

  # @return [RubyUnits::Unit, Time]
  def -(other)
    case other
    when RubyUnits::Unit
      other = other.convert_to('d').round.convert_to('s') if %w[y decade century].include? other.units
      begin
        unit_sub(other.convert_to('s').scalar)
      rescue RangeError
        send(:to_datetime) - other
      end
    else
      unit_sub(other)
    end
  end
end
