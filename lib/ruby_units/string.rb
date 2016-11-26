require 'time'
class String
  # make a string into a unit
  # @return (see RubyUnits::Unit#initialize)
  def to_unit(other = nil)
    other ? RubyUnits::Unit.new(self).convert_to(other) : RubyUnits::Unit.new(self)
  end

  alias original_format %
  # format unit output using formating codes
  # @example '%0.2f' % '1 mm'.to_unit => '1.00 mm'
  # @return [String]
  def format_with_unit(*other)
    if other.first.is_a?(RubyUnits::Unit)
      other.first.to_s(self)
    else
      original_format(*other)
    end
  end
  alias % format_with_unit

  # @param (see RubyUnits::Unit#convert_to)
  # @return (see RubyUnits::Unit#convert_to)
  def convert_to(other)
    to_unit.convert_to(other)
  end
end
