module RubyUnits
  # Performance optimizations to avoid creating units unnecessarily
  class Cache
    attr_accessor :cached

    def initialize
      @cached = {}
    end

    def get(key)
      cached[key]
    end

    def set(key, value)
      cached[key] = value
    end

    def keys
      cached.keys
    end

    def clear
      @cached = {}
    end
  end
end
