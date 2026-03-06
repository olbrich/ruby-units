# frozen_string_literal: true

# Load the C extension for ruby-units if available.
# Falls back to pure Ruby when:
#   - RUBY_UNITS_PURE=1 environment variable is set
#   - The C extension hasn't been compiled
#   - Running on a platform that doesn't support C extensions (JRuby, etc.)

unless ENV["RUBY_UNITS_PURE"]
  begin
    require_relative "ruby_units_ext"
  rescue LoadError
    # C extension not available, pure Ruby will be used
  end
end
