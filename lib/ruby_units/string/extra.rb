require 'time'

#
# String Extras
# 
# These are some extra string syntax sugar methods.  In some cases they conflict with methods defined in other 
# gems (notably with Rails).  I could make them more compatilble, but honestly they should not be here in the first place.
#
# in most cases it is better to do something like
#
# @example 
#   Unit("1 m").convert_to("ft")
#   instead of
#   "1 m".convert_to("ft")
#
# to use these methods:
# require 'ruby-units/string/extra'
class String
  
  #needed for compatibility with Rails, which defines a String.from method  
  if self.public_instance_methods.include? 'from'
    alias :old_from :from
  end 
  
  # @example 
  #   "5 min".from("now")
  # @param [Time] time_point
  # @return (see Unit#from)
  # @deprecated
  def from(time_point = ::Time.now)
    return old_from(time_point) if self.respond_to?(:old_from) && time_point.instance_of?(Integer)
    warn Kernel.caller.first + " called ruby-units/string#from, which is deprecated.  Use Unit(string).from(string) instead"
    self.unit.from(time_point)
  end
  
  alias :after :from

  # @example 
  #   "5 min".from_now
  # @return (see Unit#from)
  # @deprecated
  def from_now
    warn Kernel.caller.first + " called ruby-units/string#from_now, which is deprecated.  Use Unit(string).from(Time.now) instead"
    self.from(Time.now)
  end
  
  # @example 
  #  "5 min".ago
  # @return (see Unit#ago)
  # @deprecated
  def ago
    warn Kernel.caller.first + " called ruby-units/string#ago, which is deprecated.  Use Unit(string).ago instead"
    self.unit.ago
  end
  
  # @example 
  #  "5 min".before("now")
  # @param [Time] time_point
  # @return (see Unit#before)
  # @deprecated
  def before(time_point = ::Time.now)
    warn Kernel.caller.first + " called ruby-units/string#before, which is deprecated.  Use Unit(string).before(Time.now) instead"
    self.unit.before(time_point)
  end

  # @example 
  #  "5 min".before_now
  # @return (see Unit#before)
  # @deprecated
  def before_now
    warn Kernel.caller.first + " called ruby-units/string#before_now, which is deprecated.  Use Unit(string).before(Time.now) instead"
    self.before(Time.now)
  end
  
  # @return (see Unit#since)
  # @deprecated
  def since(time_point = ::Time.now)
    warn Kernel.caller.first + " called ruby-units/string#since, which is deprecated.  Use Unit(string).since(Time.now) instead"
    self.unit.since(time_point)
  end
  
  # @return (see Unit#until)
  # @deprecated
  def until(time_point = ::Time.now)
    warn Kernel.caller.first + " called ruby-units/string#until, which is deprecated.  Use Unit(string).until(Time.now) instead"
    self.unit.until(time_point)
  end
  
  unless String.instance_methods.include?(:to)
    # @deprecated
    # @return (see #convert_to)
    def to(other)
      warn "string.to is deprecated, use string.convert_to if you must, but the best would be Unit('unit').convert_to('target unit')"
      convert_to(other)
    end
  end
  
  # @deprecated
  # @return (see #to_time)
  def time(options = {})
    self.to_time(options) rescue self.to_datetime(options)
  end
  
  # @deprecated
  # @return [Time]
  def to_time(options = {})
    begin
      #raises exception when Chronic not defined or when it returns a nil (i.e., can't parse the input)
      r = Chronic.parse(self,options)
      raise(ArgumentError, 'Invalid Time String') unless r
      return r
    rescue 
      case
      when self == "now"
        Time.now
      when Time.respond_to?(:parse)
        Time.parse(self)
      else
        Time.local(*ParseDate.parsedate(self))
      end
    end
  end
  
  # @deprecated
  # @return [DateTime]
  def to_datetime(options = {})
    begin
      # raises an exception if Chronic.parse = nil or if Chronic not defined
      r = Chronic.parse(self,options).send(:to_datetime)
    rescue NameError  => e
      r = case
      when self.to_s == "now"
        DateTime.now
      else
        DateTime.parse(self)
      end
    end
    raise RuntimeError, "Invalid Time String (#{self.to_s})" if r == DateTime.new      
    return r
  end
  
  # @deprecated
  # @return [Date]
  def to_date(options={})
    begin
      r = Chronic.parse(self,options).to_date
    rescue
      r = case
      when self == "today" 
        Date.today
      when RUBY_VERSION < "1.9"
        Date.civil(*ParseDate.parsedate(self)[0..5].compact)
      else
        Date.parse(self)
      end
    end
    raise RuntimeError, 'Invalid Date String' if r == Date.new
    return r
  end
  
  # @deprecated
  # @return (see #to_datetime)
  def datetime(options = {})
    self.to_datetime(options) rescue self.to_time(options)
  end
end
