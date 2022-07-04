module RubyUnits
  # Math will convert unit objects to radians and then attempt to use the value for
  # trigonometric functions.
  module Math
    # Take the square root of a unit or number
    #
    # @param number [Numeric, RubyUnits::Unit]
    # @return [Numeric, RubyUnits::Unit]
    def sqrt(number)
      if number.is_a?(RubyUnits::Unit)
        (number**Rational(1, 2)).to_unit
      else
        super
      end
    end

    # Take the cube root of a unit or number
    #
    # @param number [Numeric, RubyUnits::Unit]
    # @return [Numeric, RubyUnits::Unit]
    def cbrt(number)
      if number.is_a?(RubyUnits::Unit)
        (number**Rational(1, 3)).to_unit
      else
        super
      end
    end

    # @param angle [Numeric, RubyUnits::Unit]
    # @return [Numeric]
    def sin(angle)
      angle.is_a?(RubyUnits::Unit) ? super(angle.convert_to('radian').scalar) : super
    end

    # @param number [Numeric, RubyUnits::Unit]
    # @return [Numeric, RubyUnits::Unit]
    def asin(number)
      if number.is_a?(RubyUnits::Unit)
        [super(number), 'radian'].to_unit
      else
        super
      end
    end

    # @param angle [Numeric, RubyUnits::Unit]
    # @return [Numeric]
    def cos(angle)
      angle.is_a?(RubyUnits::Unit) ? super(angle.convert_to('radian').scalar) : super
    end

    # @param number [Numeric, RubyUnits::Unit]
    # @return [Numeric, RubyUnits::Unit]
    def acos(number)
      if number.is_a?(RubyUnits::Unit)
        [super(number), 'radian'].to_unit
      else
        super
      end
    end

    # @param number [Numeric, RubyUnits::Unit]
    # @return [Numeric]
    def sinh(number)
      number.is_a?(RubyUnits::Unit) ? super(number.convert_to('radian').scalar) : super
    end

    # @param number [Numeric, RubyUnits::Unit]
    # @return [Numeric]
    def cosh(number)
      number.is_a?(RubyUnits::Unit) ? super(number.convert_to('radian').scalar) : super
    end

    # @param angle [Numeric, RubyUnits::Unit]
    # @return [Numeric]
    def tan(angle)
      angle.is_a?(RubyUnits::Unit) ? super(angle.convert_to('radian').scalar) : super
    end

    # @param number [Numeric, RubyUnits::Unit]
    # @return [Numeric]
    def tanh(number)
      number.is_a?(RubyUnits::Unit) ? super(number.convert_to('radian').scalar) : super
    end

    # @param x [Numeric, RubyUnits::Unit]
    # @param y [Numeric, RubyUnits::Unit]
    # @return [Numeric]
    def hypot(x, y)
      if x.is_a?(RubyUnits::Unit) && y.is_a?(RubyUnits::Unit)
        ((x**2) + (y**2))**Rational(1, 2)
      else
        super
      end
    end

    # @param x [Numeric, RubyUnits::Unit]
    # @param y [Numeric, RubyUnits::Unit]
    # @return [Numeric] if all parameters are numbers
    # @return [RubyUnits::Unit] if parameters are units
    # @raise [ArgumentError] if parameters are not numbers or compatible units
    def atan2(x, y)
      raise ArgumentError, 'Incompatible RubyUnits::Units' if (x.is_a?(RubyUnits::Unit) && y.is_a?(RubyUnits::Unit)) && !x.compatible?(y)

      if (x.is_a?(RubyUnits::Unit) && y.is_a?(RubyUnits::Unit)) && x.compatible?(y)
        [super(x.base_scalar, y.base_scalar), 'radian'].to_unit
      else
        super
      end
    end

    # @param number [Numeric, RubyUnits::Unit]
    # @return [Numeric]
    def log10(number)
      if number.is_a?(RubyUnits::Unit)
        super(number.to_f)
      else
        super
      end
    end

    # @param number [Numeric, RubyUnits::Unit]
    # @param base [Numeric]
    # @return [Numeric]
    def log(number, base = ::Math::E)
      if number.is_a?(RubyUnits::Unit)
        super(number.to_f, base)
      else
        super
      end
    end
  end
end

# @see https://github.com/lsegal/yard/issues/1353
module Math
  singleton_class.prepend(RubyUnits::Math)
end
