# frozen_string_literal: true

module RubyUnits
  # Extra methods for [::Array] to support conversion to [RubyUnits::Unit]
  module Array
    # Construct a unit from an array
    #
    # @example [1, 'mm'].to_unit => RubyUnits::Unit.new("1 mm")
    # @param [RubyUnits::Unit, String] other convert to same units as passed
    # @return [RubyUnits::Unit]
    def to_unit(other = nil)
      other ? RubyUnits::Unit.new(self).convert_to(other) : RubyUnits::Unit.new(self)
    end
  end
end

# @note Do this instead of Array.prepend(RubyUnits::Array) to avoid YARD warnings
# @see https://github.com/lsegal/yard/issues/1353
class Array
  prepend(RubyUnits::Array)
end
