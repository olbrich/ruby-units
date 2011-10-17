#
# String Extras
# 
# These are some extra string syntax sugar methods.  In some cases they conflict with methods defined in other 
# gems (notably with Rails).  I could make them more compatilble, but honestly they should not be here in the first place.
#
# in most cases it is better to do something like
#
# Unit("1 m").convert_to("ft")
# 
# instead of
#
# "1 m".convert_to("ft")
#
# to use these methods:
# require 'ruby-units/string/extra'

require 'time'
class String
  
  #needed for compatibility with Rails, which defines a String.from method  
  if self.public_instance_methods.include? 'from'
    alias :old_from :from
  end 
  
  # "5 min".from("now")
  def from(time_point = ::Time.now)
    return old_from(time_point) if self.respond_to?(:old_from) && time_point.instance_of?(Integer)
    warn Kernel.caller.first + " called ruby-units/string#from, which is deprecated.  Use Unit(string).from(string) instead"
    self.unit.from(time_point)
  end
  
  alias :after :from

  def from_now
    warn Kernel.caller.first + " called ruby-units/string#from_now, which is deprecated.  Use Unit(string).from(Time.now) instead"
    self.from(Time.now)
  end
  
  # "5 min".ago
  def ago
    warn Kernel.caller.first + " called ruby-units/string#ago, which is deprecated.  Use Unit(string).ago instead"
    self.unit.ago
  end
  
  def before(time_point = ::Time.now)
    warn Kernel.caller.first + " called ruby-units/string#before, which is deprecated.  Use Unit(string).before(Time.now) instead"
    self.unit.before(time_point)
  end
  
  def before_now
    warn Kernel.caller.first + " called ruby-units/string#before_now, which is deprecated.  Use Unit(string).before(Time.now) instead"
    self.before(Time.now)
  end
  
  def since(time_point = ::Time.now)
    warn Kernel.caller.first + " called ruby-units/string#since, which is deprecated.  Use Unit(string).since(Time.now) instead"
    self.unit.since(time_point)
  end
  
  def until(time_point = ::Time.now)
    warn Kernel.caller.first + " called ruby-units/string#until, which is deprecated.  Use Unit(string).until(Time.now) instead"
    self.unit.until(time_point)
  end
  
  
  unless String.instance_methods.include?(:to)
    def to(other)
      warn "string.to is deprecated, use string.convert_to if you must, but the best would be Unit('unit').convert_to('target unit')"
      convert_to(other)
    end
  end
  
  def time(options = {})
    self.to_time(options) rescue self.to_datetime(options)
  end
  
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
  
  def datetime(options = {})
    self.to_datetime(options) rescue self.to_time(options)
  end
end
