# encoding: utf-8

module RubyUnits

  # Convenience methods for strings.
  # @api private
  module StringHelper

    extend self

    # Convert a string into a unit.
    # @return (see RubyUnits::Unit#initialize)
    def string_to_unit(s, other = nil)
      other ? RubyUnits::Unit.new(s).convert_to(other) : RubyUnits::Unit.new(s)
    end

    # format unit output using formating codes 
    # @example '%0.2f' % '1 mm'.unit => '1.00 mm'
    # @return [String]
    def string_format(s, *args)
      return "" if s.empty?
      case 
      when args.first.is_a?(RubyUnits::Unit)
        args.first.to_s(s)
      when (!defined?(Uncertain).nil? && args.first.is_a?(Uncertain))
        args.first.to_s(s)
      when args.first.is_a?(Complex)
        args.first.to_s
      else
        if s.respond_to?(:unit_format)
          s.unit_format(*args)
        else
          s.%(*args)
        end
      end
    end

  end

end
