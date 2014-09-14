class Object
  
  # Shortcut for creating Unit object
  # @example 
  #   Unit("1 mm")
  #   U("1 mm")
  # @return [Unit]
  def Unit(*other)
    other.to_unit
  end
  alias :U :Unit

  # @deprecated
  alias :u :Unit
end
