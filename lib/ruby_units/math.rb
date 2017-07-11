# Math will convert unit objects to radians and then attempt to use the value for
# trigonometric functions.
module Math
  alias unit_sqrt sqrt
  # @return [Numeric]
  def sqrt(n)
    if n.is_a?(RubyUnits::Unit)
      (n**Rational(1, 2)).to_unit
    else
      unit_sqrt(n)
    end
  end
  # @return [Numeric]
  module_function :unit_sqrt
  # @return [Numeric]
  module_function :sqrt

  #:nocov:
  if respond_to?(:cbrt)
    alias unit_cbrt cbrt
    # @return [Numeric]
    def cbrt(n)
      if RubyUnits::Unit === n
        (n**Rational(1, 3)).to_unit
      else
        unit_cbrt(n)
      end
    end
    # @return [Numeric]
    module_function :unit_cbrt
    # @return [Numeric]
    module_function :cbrt
  end
  #:nocov:

  alias unit_sin sin
  # @return [Numeric]
  def sin(n)
    RubyUnits::Unit === n ? unit_sin(n.convert_to('radian').scalar) : unit_sin(n)
  end
  # @return [Numeric]
  module_function :unit_sin
  # @return [Numeric]
  module_function :sin

  alias unit_cos cos
  # @return [Numeric]
  def cos(n)
    RubyUnits::Unit === n ? unit_cos(n.convert_to('radian').scalar) : unit_cos(n)
  end
  # @return [Numeric]
  module_function :unit_cos
  # @return [Numeric]
  module_function :cos

  alias unit_sinh sinh
  # @return [Numeric]
  def sinh(n)
    RubyUnits::Unit === n ? unit_sinh(n.convert_to('radian').scalar) : unit_sinh(n)
  end
  # @return [Numeric]
  module_function :unit_sinh
  # @return [Numeric]
  module_function :sinh

  alias unit_cosh cosh
  # @return [Numeric]
  def cosh(n)
    RubyUnits::Unit === n ? unit_cosh(n.convert_to('radian').scalar) : unit_cosh(n)
  end
  # @return [Numeric]
  module_function :unit_cosh
  # @return [Numeric]
  module_function :cosh

  alias unit_tan tan
  # @return [Numeric]
  def tan(n)
    RubyUnits::Unit === n ? unit_tan(n.convert_to('radian').scalar) : unit_tan(n)
  end
  # @return [Numeric]
  module_function :tan
  # @return [Numeric]
  module_function :unit_tan

  alias unit_tanh tanh
  # @return [Numeric]
  def tanh(n)
    RubyUnits::Unit === n ? unit_tanh(n.convert_to('radian').scalar) : unit_tanh(n)
  end
  # @return [Numeric]
  module_function :unit_tanh
  # @return [Numeric]
  module_function :tanh

  alias unit_hypot hypot
  # Convert parameters to consistent units and perform the function
  # @return [Numeric]
  def hypot(x, y)
    if RubyUnits::Unit === x && RubyUnits::Unit === y
      (x**2 + y**2)**Rational(1, 2)
    else
      unit_hypot(x, y)
    end
  end
  # @return [Numeric]
  module_function :unit_hypot
  # @return [Numeric]
  module_function :hypot

  alias unit_atan2 atan2
  # @return [Numeric]
  def atan2(x, y)
    raise ArgumentError, 'Incompatible RubyUnits::Units' if (x.is_a?(RubyUnits::Unit) && y.is_a?(RubyUnits::Unit)) && !x.compatible?(y)
    if (x.is_a?(RubyUnits::Unit) && y.is_a?(RubyUnits::Unit)) && x.compatible?(y)
      Math.unit_atan2(x.base_scalar, y.base_scalar)
    else
      Math.unit_atan2(x, y)
    end
  end
  # @return [Numeric]
  module_function :unit_atan2
  # @return [Numeric]
  module_function :atan2
end
