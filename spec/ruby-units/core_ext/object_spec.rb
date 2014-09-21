require_relative "spec_helper"

describe Object do
  specify { expect(Unit('1 mm')).to be_instance_of Unit}
  specify { expect(U('1 mm')).to be_instance_of Unit}
  specify { expect(u('1 mm')).to be_instance_of Unit}
  specify { expect(Unit(0) + Unit(0)).to be_instance_of Unit}
  specify { expect(Unit(0) - Unit(0)).to be_instance_of Unit}
end
