require 'time'

module RubyUnits
  module String
    # make a string into a unit
    # @return (see RubyUnits::Unit#initialize)
    def to_unit(other = nil)
      other ? RubyUnits::Unit.new(self).convert_to(other) : RubyUnits::Unit.new(self)
    end

    # format unit output using formatting codes
    # @example '%0.2f' % '1 mm'.to_unit => '1.00 mm'
    # @return [String]
    def %(*other)
      if other.first.is_a?(RubyUnits::Unit)
        other.first.to_s(self)
      else
        super(*other)
      end
    end

    # @param (see RubyUnits::Unit#convert_to)
    # @return (see RubyUnits::Unit#convert_to)
    def convert_to(other)
      to_unit.convert_to(other)
    end
  end
end

String.prepend(RubyUnits::String)
