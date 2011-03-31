class Unit < Numeric
  module Version
    STRING = File.read(File.dirname(__FILE__) + "/../../VERSION")
  end
end