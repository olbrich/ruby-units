module RubyUnits
  # This class attempts to convert a string representation of a unit into
  # the arguments needed by {Unit.initialize} to construct a {Unit}.
  #
  # A unit representation generally belongs to a unit system, which describes a
  # consistent set of units (e.g. SI, Imperial, CGS, UCUM, etc). It is not
  # uncommon for units to be composed of more than one system.  For example, a
  # unit may have both SI and Imperial parts, or an Imperial unit may have an SI
  # prefix. These are all valid use cases, however, it may not be efficient to
  # load the definitions and include parsing information for all possible unit
  # systems at run time.
  #
  # Units generally have a format like
  #   unit = PrefixUnitname**exponent
  #   (unit * unit) / unit (?/ unit)
  #
  # where each of the components can be from any unit system.
  #
  # There are also a set of irregular unit formats like `x ft, y in`, `$xx` (currency), or `x°y'z''`.
  #
  # Approach: have a base parser class that handles the general mathematic
  # functions (multiplication, division, exponentiation), and then parse each
  # sub element by passing it to a set of registered parsers. If only one of the
  # parsers successfully parses the string, then use the output. If more than
  # one match, then there is an ambiguity problem.
  # If the basic parser fails to match then fall back to the irregular case
  # parser. By default, we need to load the SI definitions (because the internal
  # handling needs this).
  class Factory
    # @param [String] string representation of unit
    # @return [RubyUnits::Unit]
    # @todo extend this to use additional parsers if configured
    def parse(string)
      t = Time.now
      string = string.gsub(/></,'>*<')
      RubyUnits.configuration.logger.debug { "↓ Factory#parse(#{string})" }
      raise ArgumentError, 'No Unit Specified' if string =~ /^\s*$/
      begin
        result = RubyUnits::Parsers::Standard.new.parse(string)
        RubyUnits.configuration.logger.debug { "  Factory#parse(#{string}) result=#{result.inspect}" }
      rescue Parslet::ParseFailed => error
        raise(ArgumentError, "'#{string}' Unit not recognized")
      end
      RubyUnits::Transformers::Standard.new.apply(result).tap do |value|
        raise "Untransformed Unit #{value.inspect}" unless value.is_a?(Numeric)
        RubyUnits.configuration.logger.debug { "↑ Factory#parse(#{string}) = #{value} (#{Time.now - t})" }
      end
    end
  end
end
