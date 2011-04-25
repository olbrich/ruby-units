require 'time'
# make a string into a unit
class String
  def to_unit(other = nil)
    other ? Unit.new(self).to(other) : Unit.new(self)
  end
  alias :unit :to_unit
  alias :u :to_unit
  alias :unit_format :%
  
  # format unit output using formating codes '%0.2f' % '1 mm'.unit => '1.00 mm'
  def %(*args)
		return "" if self.empty?
    case 
    when args.first.is_a?(Unit)
      args.first.to_s(self)
    when (!defined?(Uncertain).nil? && args.first.is_a?(Uncertain))
      args.first.to_s(self)
    when args.first.is_a?(Complex)
      args.first.to_s
    else
      unit_format(*args)
    end
  end
  
  #needed for compatibility with Rails, which defines a String.from method  
  if self.public_instance_methods.include? 'from'
    alias :old_from :from
  end 
  
  # "5 min".from("now")
  def from(time_point = ::Time.now)
    return old_from(time_point) if self.respond_to?(:old_from) && time_point.instance_of?(Integer)
    self.unit.from(time_point)
  end
  
  alias :after :from

  def from_now
    self.from('now')
  end
  
  # "5 min".ago
  def ago
    self.unit.ago
  end
  
  def before(time_point = ::Time.now)
    self.unit.before(time_point)
  end
  
  def before_now
    self.before('now')
  end
  
  def since(time_point = ::Time.now)
    self.unit.since(time_point)
  end
  
  def until(time_point = ::Time.now)
    self.unit.until(time_point)
  end
  
  def to(other)
    self.unit.to(other)
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
    rescue Exception  => e
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
