class Numeric
  # make a unitless unit with a given scalar
  # @return (see RubyUnits::Unit#initialize)
  def to_unit(other = nil)
    other ? RubyUnits::Unit.new(self, other) : RubyUnits::Unit.new(self)
  end
end
