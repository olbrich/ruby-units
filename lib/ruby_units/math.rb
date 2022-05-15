# Math will convert unit objects to radians and then attempt to use the value for
# trigonometric functions.
module RubyUnits
  module Math
    # @param number [Numeric]
    # @return [Numeric]
    def sqrt(number)
      if number.is_a?(RubyUnits::Unit)
        (number**Rational(1, 2)).to_unit
      else
        super(number)
      end
    end

    # @param number [Numeric]
    # @return [Numeric]
    def cbrt(number)
      if number.is_a?(RubyUnits::Unit)
        (number**Rational(1, 3)).to_unit
      else
        super(number)
      end
    end

    # @param n [Numeric]
    # @return [Numeric]
    def sin(n)
      n.is_a?(RubyUnits::Unit) ? super(n.convert_to('radian').scalar) : super(n)
    end

    # @param n [Numeric]
    # @return [Numeric]
    def cos(n)
      n.is_a?(RubyUnits::Unit) ? super(n.convert_to('radian').scalar) : super(n)
    end

    # @param n [Numeric]
    # @return [Numeric]
    def sinh(n)
      n.is_a?(RubyUnits::Unit) ? super(n.convert_to('radian').scalar) : super(n)
    end

    # @param n [Numeric]
    # @return [Numeric]
    def cosh(n)
      n.is_a?(RubyUnits::Unit) ? super(n.convert_to('radian').scalar) : super(n)
    end

    # @param n [Numeric]
    # @return [Numeric]
    def tan(n)
      n.is_a?(RubyUnits::Unit) ? super(n.convert_to('radian').scalar) : super(n)
    end

    # @param n [Numeric]
    # @return [Numeric]
    def tanh(n)
      n.is_a?(RubyUnits::Unit) ? super(n.convert_to('radian').scalar) : super(n)
    end

    # Convert parameters to consistent units and perform the function
    # @param x [Numeric]
    # @param y [Numeric]
    # @return [Numeric]
    def hypot(x, y)
      if x.is_a?(RubyUnits::Unit) && y.is_a?(RubyUnits::Unit)
        ((x**2) + (y**2))**Rational(1, 2)
      else
        super(x, y)
      end
    end

    # @param x [Numeric]
    # @param y [Numeric]
    # @return [Numeric]
    def atan2(x, y)
      raise ArgumentError, 'Incompatible RubyUnits::Units' if (x.is_a?(RubyUnits::Unit) && y.is_a?(RubyUnits::Unit)) && !x.compatible?(y)

      if (x.is_a?(RubyUnits::Unit) && y.is_a?(RubyUnits::Unit)) && x.compatible?(y)
        super(x.base_scalar, y.base_scalar)
      else
        super(x, y)
      end
    end

    # @param number [Numeric]
    # @return [Numeric]
    def log10(number)
      if number.is_a?(RubyUnits::Unit)
        super(number.to_f)
      else
        super(number)
      end
    end

    # @param number [Numeric]
    # @param base [Numeric]
    # @return [Numeric]
    def log(number, base = ::Math::E)
      if number.is_a?(RubyUnits::Unit)
        super(number.to_f, base)
      else
        super(number, base)
      end
    end
  end
end

Math.singleton_class.prepend(RubyUnits::Math)
