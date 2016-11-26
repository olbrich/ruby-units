module RubyUnits
  class Unit < Numeric
    @@cached_units = {}

    class Cache
      def self.get(key = nil)
        key.nil? ? @@cached_units : @@cached_units[key]
      end

      def self.set(key, value)
        @@cached_units[key] = value
      end

      def self.clear
        @@cached_units = {}
        @@base_unit_cache = {}
        Unit.new(1)
      end
    end
  end
end
