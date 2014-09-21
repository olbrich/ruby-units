# encoding: utf-8

module RubyUnits

  # Convenience methods for dates.
  # @api private
  module DateHelper

    extend self

    # @param [Object] unit
    # @return [Unit]
    def date_add(date, unit)
      if unit.is_a?(Unit)
        if ['y', 'decade', 'century'].include? unit.units 
          unit = unit.convert_to('d').round
        end
        unit = unit.convert_to('day').scalar
      end
      if date.respond_to?(:unit_date_add)
        date.unit_date_add(unit)
      else
        date.+(unit)
      end
    end

    # @param [Object] unit
    # @return [Unit]
    def date_sub(date, unit)
      if unit.is_a?(Unit)
        if ['y', 'decade', 'century'].include? unit.units 
          unit = unit.convert_to('d').round
        end
        unit = unit.convert_to('day').scalar
      end
      if date.respond_to?(:unit_date_sub)
        date.unit_date_sub(unit)
      else
        date.-(unit)
      end
    end

  end

end
