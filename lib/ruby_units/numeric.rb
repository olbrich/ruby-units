class Numeric
  # make a unitless unit with a given scalar
  # @return (see Unit#initialize)
  def to_unit(other = nil)
    other ? Unit.new(self, other) : Unit.new(self)
  end
  alias :unit :to_unit
  alias :u :to_unit
end
