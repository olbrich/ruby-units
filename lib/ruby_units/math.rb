# frozen_string_literal: true

module RubyUnits
  # Extends Ruby's Math module to support RubyUnits::Unit objects.
  #
  # This module provides unit-aware versions of standard mathematical functions.
  # When a Unit object is passed to these functions, it handles unit conversions
  # automatically:
  #
  # - Trigonometric functions (sin, cos, tan, etc.) convert angle units to radians
  # - Inverse trigonometric functions return results as Unit objects in radians
  # - Root functions (sqrt, cbrt) preserve dimensional analysis
  # - Logarithmic functions extract scalar values from units
  # - hypot and atan2 handle units properly for vector calculations
  #
  # @example Using trigonometric functions with units
  #   Math.sin(Unit.new("90 deg"))      #=> 1.0
  #   Math.cos(Unit.new("180 deg"))     #=> -1.0
  #   Math.tan(Unit.new("45 deg"))      #=> 1.0
  #
  # @example Using inverse trigonometric functions
  #   Math.asin(0.5)                     #=> Unit.new("0.524 rad")
  #   Math.atan(1)                       #=> Unit.new("0.785 rad")
  #
  # @example Using root functions with units
  #   Math.sqrt(Unit.new("4 m^2"))      #=> Unit.new("2 m")
  #   Math.cbrt(Unit.new("27 m^3"))     #=> Unit.new("3 m")
  #
  # @example Using hypot for distance calculations
  #   Math.hypot(Unit.new("3 m"), Unit.new("4 m"))  #=> Unit.new("5 m")
  #
  # @note This module is prepended to Ruby's Math singleton class, so all functions
  #   work seamlessly with both regular numbers and Unit objects.
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

    # Calculate the sine of an angle.
    #
    # If the angle is a Unit object, it will be converted to radians before calculation.
    #
    # @param angle [Numeric, RubyUnits::Unit] angle in radians or any angular unit
    # @return [Numeric] the sine of the angle (dimensionless)
    # @example
    #   Math.sin(Unit.new("90 deg"))   #=> 1.0
    #   Math.sin(Math::PI / 2)         #=> 1.0
    def sin(angle)
      angle.is_a?(RubyUnits::Unit) ? super(angle.convert_to("radian").scalar) : super
    end

    # Calculate the arcsine (inverse sine) of a number.
    #
    # @param number [Numeric, RubyUnits::Unit] a dimensionless value between -1 and 1
    # @return [Numeric, RubyUnits::Unit] angle in radians (as Unit if input was Unit)
    # @example
    #   Math.asin(0.5)   #=> Unit.new("0.524 rad")
    #   Math.asin(1)     #=> Unit.new("1.571 rad")
    def asin(number)
      if number.is_a?(RubyUnits::Unit)
        [super, "radian"].to_unit
      else
        super
      end
    end

    # Calculate the cosine of an angle.
    #
    # If the angle is a Unit object, it will be converted to radians before calculation.
    #
    # @param angle [Numeric, RubyUnits::Unit] angle in radians or any angular unit
    # @return [Numeric] the cosine of the angle (dimensionless)
    # @example
    #   Math.cos(Unit.new("180 deg"))  #=> -1.0
    #   Math.cos(Math::PI)              #=> -1.0
    def cos(angle)
      angle.is_a?(RubyUnits::Unit) ? super(angle.convert_to("radian").scalar) : super
    end

    # Calculate the arccosine (inverse cosine) of a number.
    #
    # @param number [Numeric, RubyUnits::Unit] a dimensionless value between -1 and 1
    # @return [Numeric, RubyUnits::Unit] angle in radians (as Unit if input was Unit)
    # @example
    #   Math.acos(0)      #=> Unit.new("1.571 rad")
    #   Math.acos(-1)     #=> Unit.new("3.142 rad")
    def acos(number)
      if number.is_a?(RubyUnits::Unit)
        [super, "radian"].to_unit
      else
        super
      end
    end

    # Calculate the hyperbolic sine of a number.
    #
    # If the input is a Unit object, it will be converted to radians before calculation.
    #
    # @param number [Numeric, RubyUnits::Unit] angle in radians or any angular unit
    # @return [Numeric] the hyperbolic sine (dimensionless)
    def sinh(number)
      number.is_a?(RubyUnits::Unit) ? super(number.convert_to("radian").scalar) : super
    end

    # Calculate the hyperbolic cosine of a number.
    #
    # If the input is a Unit object, it will be converted to radians before calculation.
    #
    # @param number [Numeric, RubyUnits::Unit] angle in radians or any angular unit
    # @return [Numeric] the hyperbolic cosine (dimensionless)
    def cosh(number)
      number.is_a?(RubyUnits::Unit) ? super(number.convert_to("radian").scalar) : super
    end

    # Calculate the tangent of an angle.
    #
    # If the angle is a Unit object, it will be converted to radians before calculation.
    #
    # @param angle [Numeric, RubyUnits::Unit] angle in radians or any angular unit
    # @return [Numeric] the tangent of the angle (dimensionless)
    # @example
    #   Math.tan(Unit.new("45 deg"))  #=> 1.0
    #   Math.tan(Math::PI / 4)         #=> 1.0
    def tan(angle)
      angle.is_a?(RubyUnits::Unit) ? super(angle.convert_to("radian").scalar) : super
    end

    # Calculate the hyperbolic tangent of a number.
    #
    # If the input is a Unit object, it will be converted to radians before calculation.
    #
    # @param number [Numeric, RubyUnits::Unit] angle in radians or any angular unit
    # @return [Numeric] the hyperbolic tangent (dimensionless)
    def tanh(number)
      number.is_a?(RubyUnits::Unit) ? super(number.convert_to("radian").scalar) : super
    end

    # Calculate the hypotenuse (Euclidean distance) of a right triangle.
    #
    # Returns sqrt(x² + y²). If both parameters are Unit objects, the result
    # will be a Unit object with the same dimensions.
    #
    # @param x [Numeric, RubyUnits::Unit] first side of the triangle
    # @param y [Numeric, RubyUnits::Unit] second side of the triangle
    # @return [Numeric, RubyUnits::Unit] the hypotenuse length
    # @example
    #   Math.hypot(Unit.new("3 m"), Unit.new("4 m"))  #=> Unit.new("5 m")
    #   Math.hypot(3, 4)                               #=> 5.0
    # :reek:UncommunicativeParameterName
    def hypot(x, y)
      if x.is_a?(RubyUnits::Unit) && y.is_a?(RubyUnits::Unit)
        ((x**2) + (y**2))**Rational(1, 2)
      else
        super
      end
    end

    # Calculate the arctangent (inverse tangent) of a number.
    #
    # @param number [Numeric, RubyUnits::Unit] a dimensionless value
    # @return [Numeric] if argument is a number
    # @return [RubyUnits::Unit] angle in radians if argument is a unit
    # @example
    #   Math.atan(1)   #=> Unit.new("0.785 rad")
    #   Math.atan(0)   #=> Unit.new("0 rad")
    def atan(number)
      if number.is_a?(RubyUnits::Unit)
        [super, "radian"].to_unit
      else
        super
      end
    end

    # Calculate the arctangent of y/x using the signs of both to determine the quadrant.
    #
    # This is useful for converting Cartesian coordinates to polar coordinates.
    # If both parameters are Unit objects, they must have compatible dimensions.
    #
    # @param x [Numeric, RubyUnits::Unit] x-coordinate
    # @param y [Numeric, RubyUnits::Unit] y-coordinate
    # @return [Numeric] angle in radians if parameters are numbers
    # @return [RubyUnits::Unit] angle in radians if parameters are units
    # @raise [ArgumentError] if parameters are incompatible units
    # @example
    #   Math.atan2(Unit.new("1 m"), Unit.new("1 m"))  #=> Unit.new("0.785 rad")
    #   Math.atan2(1, 1)                               #=> 0.7853981633974483
    # :reek:UncommunicativeParameterName
    # :reek:UncommunicativeMethodName
    # :reek:TooManyStatements
    def atan2(x, y)
      x_is_unit = x.is_a?(RubyUnits::Unit)
      y_is_unit = y.is_a?(RubyUnits::Unit)
      both_units = x_is_unit && y_is_unit
      units_compatible = both_units && x.compatible?(y)

      raise ArgumentError, "Incompatible RubyUnits::Units" if both_units && !units_compatible

      if units_compatible
        [super(x.base_scalar, y.base_scalar), "radian"].to_unit
      else
        super
      end
    end

    # Calculate the base-10 logarithm of a number.
    #
    # If the input is a Unit object, the scalar value is extracted before calculation.
    #
    # @param number [Numeric, RubyUnits::Unit] a positive number
    # @return [Numeric] the base-10 logarithm (dimensionless)
    # @example
    #   Math.log10(Unit.new("100"))  #=> 2.0
    #   Math.log10(1000)              #=> 3.0
    # :reek:UncommunicativeMethodName
    def log10(number)
      if number.is_a?(RubyUnits::Unit)
        super(number.scalar)
      else
        super
      end
    end

    # Calculate the logarithm of a number with a specified base.
    #
    # If the input is a Unit object, the scalar value is extracted before calculation.
    # Defaults to natural logarithm (base e) if no base is specified.
    #
    # @param number [Numeric, RubyUnits::Unit] a positive number
    # @param base [Numeric] the logarithm base (defaults to e)
    # @return [Numeric] the logarithm (dimensionless)
    # @example
    #   Math.log(Unit.new("2.718"))        #=> ~1.0 (natural log)
    #   Math.log(Unit.new("8"), 2)         #=> 3.0 (log base 2)
    #   Math.log(Math::E)                  #=> 1.0
    def log(number, base = ::Math::E)
      if number.is_a?(RubyUnits::Unit)
        super(number.scalar, base)
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
