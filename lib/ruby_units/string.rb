require 'time'
class String
  # make a string into a unit
  # @return (see Unit#initialize)
  def to_unit(other = nil)
    other ? Unit.new(self).convert_to(other) : Unit.new(self)
  end
  alias :unit :to_unit
  alias :u :to_unit


  alias :unit_format :%  
  # format unit output using formating codes 
  # @example '%0.2f' % '1 mm'.unit => '1.00 mm'
  # @return [String]
  def %(*args)
		return "" if self.empty?
    case 
    when args.first.is_a?(Unit)
      args.first.to_s(self)
    when (!defined?(Uncertain).nil? && args.first.is_a?(Uncertain))
      args.first.to_s(self)
    when (!defined?(Complex).nil? && args.first.is_a?(Complex))
      args.first.to_s
    else
      unit_format(*args)
    end
  end
  
  # @param (see Unit#convert_to)
  # @return (see Unit#convert_to)
  def convert_to(other)
    self.unit.convert_to(other)
  end
end
