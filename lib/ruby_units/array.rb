class Array
  # Construct a unit from an array
  # @example [1, 'mm'].to_unit => Unit("1 mm")
  # @return (see Unit#initialize)
  # @param [Object] other convert to same units as passed
  def to_unit(other = nil)
    other ? Unit.new(self).convert_to(other) : Unit.new(self)
  end
  alias :unit :to_unit
  alias :u :to_unit
end