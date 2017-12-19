module RubyUnits
  module Parsers
    class Metric < Parslet::Parser
      rule(:zero) { str('0') }
      rule(:unsigned_integer) { zero | match('[1-9]') >> match('[0-9]').repeat }
      rule(:sign) { str('+') | str('-') }
      rule(:sign?) { sign.maybe }
      rule(:integer) { sign? >> unsigned_integer }
      root(:integer)
    end
  end
end
