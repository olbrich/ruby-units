# frozen_string_literal: true

module RubyUnits
  # Performance optimizations to avoid creating units unnecessarily
  class Cache
    attr_accessor :data

    def initialize
      clear
    end

    # @param key [String, #to_unit]
    # @return [RubyUnits::Unit, nil]
    def get(key)
      key = key&.to_unit&.units unless key.is_a?(String)
      data[key]
    end

    # @param key [String, #to_unit]
    # @return [void]
    def set(key, value)
      key = key.to_unit.units unless key.is_a?(String)
      return if should_skip_caching?(key)

      data[key] = value
    end

    # @return [Array<String>]
    def keys
      data.keys
    end

    # Reset the cache
    def clear
      @data = {}
    end

    def should_skip_caching?(key)
      keys.include?(key) || key =~ RubyUnits::Unit.special_format_regex
    end
  end
end
