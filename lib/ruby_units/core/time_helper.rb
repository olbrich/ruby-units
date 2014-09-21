# encoding: utf-8

module RubyUnits

  # Convenience methods for times.
  # @api private
  module TimeHelper

    extend self
  
    # @return [RubyUnits::Unit, Time]
    def time_add(time, other)
      case other
      when RubyUnits::Unit
        if ['y', 'decade', 'century'].include? other.units
          other = other.convert_to('d').round.convert_to('s')
        end
        begin
          time_unit_add(time, other.convert_to('s').scalar)
        rescue RangeError
          self.to_datetime + other
        end
      else
        time_unit_add(time, other)
      end
    end

    def time_unit_add(time, other)
      if time.respond_to?(:unit_add)
        time.unit_add(other)
      else
        time + other
      end
    end

    # @return [RubyUnits::Unit, Time]
    def time_sub(time, other)
      case other
      when RubyUnits::Unit
        other = other.convert_to('d').round.convert_to('s') if ['y', 'decade', 'century'].include? other.units  
        begin
          time_unit_sub(time, other.convert_to('s').scalar)
        rescue RangeError
          self.send(:to_datetime) - other
        end
      else
        time_unit_sub(time, other)
      end
    end

    def time_unit_sub(time, other)
      if time.respond_to?(:unit_sub)
        time.unit_sub(other)
      else
        time - other
      end
    end

  end

end
