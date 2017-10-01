require 'date'

# Allow date objects to do offsets by a time unit
# Date.today + Unit.new("1 week") => gives today+1 week
class Date
  alias unit_date_add +
  # @param [Object] other
  # @return [Unit]
  def +(other)
    case other
    when RubyUnits::Unit
      other = other.convert_to('d').round if %w[y decade century].include? other.units
      unit_date_add(other.convert_to('day').scalar)
    else
      unit_date_add(other)
    end
  end

  alias unit_date_sub -
  # @param [Object] other
  # @return [Unit]
  def -(other)
    case other
    when RubyUnits::Unit
      other = other.convert_to('d').round if %w[y decade century].include? other.units
      unit_date_sub(other.convert_to('day').scalar)
    else
      unit_date_sub(other)
    end
  end

  # Construct a unit from a Date
  # @example Date.today.to_unit => Unit
  # @return (see Unit#initialize)
  # @param [Object] other convert to same units as passed
  def to_unit(other = nil)
    other ? RubyUnits::Unit.new(self).convert_to(other) : RubyUnits::Unit.new(self)
  end

  # :nocov_19:
  unless Date.instance_methods.include?(:to_time)
    # @return [Time]
    def to_time
      Time.local(*ParseDate.parsedate(to_s))
    end
  end
  # :nocov_19:

  alias units_datetime_inspect inspect
  # @deprecated
  def inspect(dump = false)
    return units_datetime_inspect if dump
    to_s
  end

  unless Date.instance_methods.include?(:to_date)
    # :nocov_19:
    # @return [Date]
    def to_date
      Date.civil(year, month, day)
    end
    # :nocov_19:
  end
end
