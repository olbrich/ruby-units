class Complex < Numeric
  def to_unit(other = nil)
    real_unit = self.real.to_unit
    image_unit = self.image.to_unit
    raise ArgumentError, 'Units on real and imaginary parts are incompatible' unless real_unit =~ image_unit 
    final_unit = (real_unit.units.empty? ? image_unit.units : real_unit.units).to_unit
    final_unit * Complex(real_unit.to(final_unit).scalar, image_unit.to(final_unit).scalar)
  end
  alias :unit :to_unit
end