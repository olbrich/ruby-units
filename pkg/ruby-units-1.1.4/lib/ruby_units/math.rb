# Math will convert unit objects to radians and then attempt to use the value for 
# trigonometric functions.  

module Math
  alias unit_sqrt sqrt
  def sqrt(n)
    if Unit === n
      (n**(1/2)).to_unit 
    else
      unit_sqrt(n)
    end
  end
  
  alias unit_sin sin
  def sin(n)
   Unit === n ? unit_sin(n.to('radian').scalar) : unit_sin(n)
  end

  alias unit_cos cos
  def cos(n)
    Unit === n ? unit_cos(n.to('radian').scalar) : unit_cos(n)
  end
    
  alias unit_sinh sinh
  def sinh(n)
    Unit === n ? unit_sinh(n.to('radian').scalar) : unit_sinh(n)
  end

  alias unit_cosh cosh
  def cosh(n)
    Unit === n ? unit_cosh(n.to('radian').scalar) : unit_cosh(n)
  end

  alias unit_tan tan
  def tan(n)
   Unit === n ? unit_tan(n.to('radian').scalar) : unit_tan(n)
  end

  alias unit_tanh tanh
  def tanh(n)
    Unit === n ? unit_tanh(n.to('radian').scalar) : unit_tanh(n)
  end

  alias unit_hypot hypot
  # Convert parameters to consistent units and perform the function
  def hypot(x,y)
    if Unit === x && Unit === y
      (x**2 + y**2)**(1/2)
    else
      unit_hypot(x,y)
    end
  end
  
  alias unit_atan2 atan2
  def atan2(x,y)
    case
    when (Unit === x && Unit === y) && (x !~ y)
      raise ArgumentError, "Incompatible Units"
    when (Unit === x && Unit === y) && (x =~ y)
      unit_atan2(x.base_scalar, y.base_scalar)
    when (Unit === x || Unit === y)
      raise ArgumentError, "Incompatible Units"
    else
      unit_atan2(x,y)
    end
  end

   module_function :unit_hypot
   module_function :hypot
   module_function :unit_sqrt
   module_function :sqrt
   module_function :unit_sin
   module_function :sin
   module_function :unit_cos
   module_function :cos
   module_function :unit_sinh
   module_function :sinh
   module_function :unit_cosh
   module_function :cosh
   module_function :unit_tan
   module_function :tan
   module_function :unit_tanh
   module_function :tanh
   module_function :unit_atan2
   module_function :atan2
   
end