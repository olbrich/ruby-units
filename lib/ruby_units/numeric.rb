module RubyUnits
  # Extra methods for [::Numeric] to allow it to be used as a [RubyUnits::Unit]
  module Numeric
    # Make a unitless unit with a given scalar.
    # > In ruby-units <= 2.3.2 this method would create a new [RubyUnits::Unit]
    # > with the scalar and passed in units. This was changed to be more
    # > consistent with the behavior of [#to_unit]. Specifically the argument is
    # > used as a convenience method to convert the unitless scalar unit to a
    # > compatible unitless unit.
    #
    # @param other [RubyUnits::Unit, String] convert to same units as passed
    # @return [RubyUnits::Unit]
    def to_unit(other = nil)
      other ? RubyUnits::Unit.new(self).convert_to(other) : RubyUnits::Unit.new(self)
    end
  end
end

Numeric.prepend(RubyUnits::Numeric)
