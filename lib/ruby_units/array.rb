class Array
  # Construct a unit from an array
  # @example [1, 'mm'].to_unit => RubyUnits::Unit.new("1 mm")
  # @return (see RubyUnits::Unit#initialize)
  # @param [Object] other convert to same units as passed
  def to_unit(other = nil)
    other ? RubyUnits::Unit.new(self).convert_to(other) : RubyUnits::Unit.new(self)
  end
end
