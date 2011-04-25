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
  def self.at(arg)
    case arg
    when Unit
      unit_time_at(arg.to("s").scalar)
    else
      unit_time_at(arg)
    end
  end
  
  def to_unit(other = nil)
    other ? Unit.new(self).to(other) : Unit.new(self)
  end
  alias :unit :to_unit
  alias :u :to_unit
  alias :unit_add :+
  
  unless Time.instance_methods.include?(:to_date)
    def to_date
      x=(Date.civil(1970,1,1)+((self.to_f+self.gmt_offset)/86400.0)-0.5)
      Date.civil(x.year, x.month, x.day)
    end
  end
  
  def +(other)
    case other
    when Unit
      other = other.to('d').round.to('s') if ['y', 'decade', 'century'].include? other.units  
      begin
        unit_add(other.to('s').scalar)
      rescue RangeError
        self.to_datetime + other
      end
    else
      unit_add(other)
    end
  end
  
  # usage: Time.in '5 min'
  def self.in(duration)
    Time.now + duration.to_unit
  end
  
  alias :unit_sub :-
  
  def -(other)
    case other
    when Unit
      other = other.to('d').round.to('s') if ['y', 'decade', 'century'].include? other.units  
      begin
        unit_sub(other.to('s').scalar)
      rescue RangeError
        self.send(:to_datetime) - other
      end
    else
      unit_sub(other)
    end
  end
end
