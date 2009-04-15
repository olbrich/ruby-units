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
    case 
    when Unit === args[0]: args[0].to_s(self)
    when (!defined?(Uncertain).nil? && (Uncertain === args[0])): args[0].to_s(self)
    when Complex === args[0]: args[0].to_s
    else
      unit_format(*args)
    end
  end
  
  #needed for compatibility with Rails, which defines a String.from method  
  if self.public_instance_methods.include? 'from'
    alias :old_from :from
  end 
  
  def from(time_point = ::Time.now)
    return old_from(time_point) if Integer === time_point
    self.unit.from(time_point)
  end
  
  alias :after :from
  alias :from_now :from
  
  def ago
    self.unit.ago
  end
  
  def before(time_point = ::Time.now)
    self.unit.before(time_point)
  end
  alias :before_now :before
  
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
      Time.local(*ParseDate.parsedate(self))
    end
  end
  
  def to_datetime(options = {})
    begin
      # raises an exception if Chronic.parse = nil or if Chronic not defined
      r = Chronic.parse(self,options).to_datetime
    rescue
      r=DateTime.civil(*ParseDate.parsedate(self)[0..5].compact)
    end
    raise RuntimeError, "Invalid Time String" if r == DateTime.new      
    return r
  end
  
  def to_date(options={})
    begin
      r = Chronic.parse(self,options).to_date
    rescue
      r = Date.civil(*ParseDate.parsedate(self)[0..5].compact)
    end
    raise RuntimeError, 'Invalid Date String' if r == Date.new
    return r
  end

  def datetime(options = {})
    self.to_datetime(options) rescue self.to_time(options)
  end
end
