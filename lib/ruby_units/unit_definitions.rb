# frozen_string_literal: true

RubyUnits::Unit.batch_define do
  require_relative "unit_definitions/prefix"
  require_relative "unit_definitions/base"
  require_relative "unit_definitions/standard"
end
