module RubyUnits
  class Unit < Numeric
    # Pull the version number from the VERSION file
    module Version
      STRING = File.read(File.dirname(__FILE__) + '/../../VERSION')
    end
  end
end
