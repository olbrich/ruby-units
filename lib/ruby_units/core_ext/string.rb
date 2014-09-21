require 'time'

class String

  # Convert a string into a unit.
  # @return (see RubyUnits::Unit#initialize)
  def to_unit(other = nil)
    RubyUnits::StringHelper.string_to_unit(self, other)
  end
  alias :unit :to_unit
  alias :u :to_unit

  alias :unit_format :%  

  # format unit output using formating codes 
  # @example '%0.2f' % '1 mm'.unit => '1.00 mm'
  # @return [String]
  def %(*args)
    RubyUnits::StringHelper.string_format(self, *args)
  end
  
  # @param (see RubyUnits::Unit#convert_to)
  # @return (see RubyUnits::Unit#convert_to)
  def convert_to(other)
    self.unit.convert_to(other)
  end
end
