# make a unit from an array
# [1, 'mm'].unit => 1 mm
class Array
  def to_unit(other = nil)
    other ? Unit.new(self).to(other) : Unit.new(self)
  end
  alias :unit :to_unit
  alias :u :to_unit
end