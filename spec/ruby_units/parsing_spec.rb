require 'spec_helper'

RSpec.describe 'Number parsing' do
  context 'with Integers' do
    it { expect(RubyUnits::Unit.new('1')).to have_attributes(scalar: 1) }
    it { expect(RubyUnits::Unit.new('-1')).to have_attributes(scalar: -1) }
    it { expect(RubyUnits::Unit.new('+1')).to have_attributes(scalar: 1) }
    it { expect(RubyUnits::Unit.new('01')).to have_attributes(scalar: 1) }
    it { expect(RubyUnits::Unit.new('1,000')).to have_attributes(scalar: 1000) }
    it { expect(RubyUnits::Unit.new('1_000')).to have_attributes(scalar: 1000) }
  end

  context 'with Decimals' do
    # NOTE: that since this float is the same as an integer, the integer is returned
    it { expect(RubyUnits::Unit.new('1.0').scalar).to be(1) }
    it { expect(RubyUnits::Unit.new('-1.0').scalar).to be(-1) }

    it { expect(RubyUnits::Unit.new('1.1').scalar).to be(1.1) }
    it { expect(RubyUnits::Unit.new('-1.1').scalar).to be(-1.1) }
    it { expect(RubyUnits::Unit.new('+1.1').scalar).to be(1.1) }
    it { expect(RubyUnits::Unit.new('0.1').scalar).to be(0.1) }
    it { expect(RubyUnits::Unit.new('-0.1').scalar).to be(-0.1) }
    it { expect(RubyUnits::Unit.new('+0.1').scalar).to be(0.1) }
    it { expect(RubyUnits::Unit.new('.1').scalar).to be(0.1) }
    it { expect(RubyUnits::Unit.new('-.1').scalar).to be(-0.1) }
    it { expect(RubyUnits::Unit.new('+.1').scalar).to be(0.1) }

    it { expect { RubyUnits::Unit.new('0.1.') }.to raise_error(ArgumentError) }
    it { expect { RubyUnits::Unit.new('-0.1.') }.to raise_error(ArgumentError) }
    it { expect { RubyUnits::Unit.new('+0.1.') }.to raise_error(ArgumentError) }
  end

  context 'with Fractions' do
    it { expect(RubyUnits::Unit.new('1/1').scalar).to be(1) }
    it { expect(RubyUnits::Unit.new('-1/1').scalar).to be(-1) }
    it { expect(RubyUnits::Unit.new('+1/1').scalar).to be(1) }

    # NOTE: eql? is used here because two equivalent Rational objects are not the same object, unlike Integers
    it { expect(RubyUnits::Unit.new('1/2').scalar).to eql(1/2r) }
    it { expect(RubyUnits::Unit.new('-1/2').scalar).to eql(-1/2r) }
    it { expect(RubyUnits::Unit.new('+1/2').scalar).to eql(1/2r) }
    it { expect(RubyUnits::Unit.new('(1/2)').scalar).to eql(1/2r) }
    it { expect(RubyUnits::Unit.new('(-1/2)').scalar).to eql(-1/2r) }
    it { expect(RubyUnits::Unit.new('(+1/2)').scalar).to eql(1/2r) }

    # improper fractions
    it { expect(RubyUnits::Unit.new('1 1/2').scalar).to eql(3/2r) }
    it { expect(RubyUnits::Unit.new('-1 1/2').scalar).to eql(-3/2r) }
    it { expect(RubyUnits::Unit.new('+1 1/2').scalar).to eql(3/2r) }
    it { expect(RubyUnits::Unit.new('1-1/2').scalar).to eql(3/2r) }
    it { expect(RubyUnits::Unit.new('-1-1/2').scalar).to eql(-3/2r) }
    it { expect(RubyUnits::Unit.new('+1-1/2').scalar).to eql(3/2r) }
    it { expect(RubyUnits::Unit.new('1 2/2').scalar).to be(2) } # weird, but not wrong
    it { expect(RubyUnits::Unit.new('1 3/2').scalar).to eql(5/2r) } # weird, but not wrong
    it { expect { RubyUnits::Unit.new('1.5 1/2') }.to raise_error(ArgumentError, 'Improper fractions must have a whole number part') }
    it { expect { RubyUnits::Unit.new('1.5/2') }.to raise_error(ArgumentError, 'invalid value for Integer(): "1.5"') }
    it { expect { RubyUnits::Unit.new('1/2.5') }.to raise_error(ArgumentError, 'invalid value for Integer(): "2.5"') }
  end

  context 'with Scientific Notation' do
    it { expect(RubyUnits::Unit.new('1e0').scalar).to be(1) }
    it { expect(RubyUnits::Unit.new('-1e0').scalar).to be(-1) }
    it { expect(RubyUnits::Unit.new('+1e0').scalar).to be(1) }
    it { expect(RubyUnits::Unit.new('1e1').scalar).to be(10) }
    it { expect(RubyUnits::Unit.new('-1e1').scalar).to be(-10) }
    it { expect(RubyUnits::Unit.new('+1e1').scalar).to be(10) }
    it { expect(RubyUnits::Unit.new('1e-1').scalar).to be(0.1) }
    it { expect(RubyUnits::Unit.new('-1e-1').scalar).to be(-0.1) }
    it { expect(RubyUnits::Unit.new('+1e-1').scalar).to be(0.1) }
    it { expect(RubyUnits::Unit.new('1E+1').scalar).to be(10) }
    it { expect(RubyUnits::Unit.new('-1E+1').scalar).to be(-10) }
    it { expect(RubyUnits::Unit.new('+1E+1').scalar).to be(10) }
    it { expect(RubyUnits::Unit.new('1E-1').scalar).to be(0.1) }
    it { expect(RubyUnits::Unit.new('-1E-1').scalar).to be(-0.1) }
    it { expect(RubyUnits::Unit.new('+1E-1').scalar).to be(0.1) }
    it { expect(RubyUnits::Unit.new('1.0e2').scalar).to be(100) }
    it { expect(RubyUnits::Unit.new('.1e2').scalar).to be(10) }
    it { expect(RubyUnits::Unit.new('0.1e2').scalar).to be(10) }
    it { expect { RubyUnits::Unit.new('0.1e2.5') }.to raise_error(ArgumentError) }
  end

  context 'with Complex numbers' do
    it { expect(RubyUnits::Unit.new('1+1i').scalar).to eql(Complex(1, 1)) }
    it { expect(RubyUnits::Unit.new('1i').scalar).to eql(Complex(0, 1)) }
    it { expect(RubyUnits::Unit.new('-1i').scalar).to eql(Complex(0, -1)) }
    it { expect(RubyUnits::Unit.new('-1+1i').scalar).to eql(Complex(-1, 1)) }
    it { expect(RubyUnits::Unit.new('+1+1i').scalar).to eql(Complex(1, 1)) }
    it { expect(RubyUnits::Unit.new('1-1i').scalar).to eql(Complex(1, -1)) }
    it { expect(RubyUnits::Unit.new('-1.23-4.5i').scalar).to eql(Complex(-1.23, -4.5)) }
    it { expect(RubyUnits::Unit.new('1+0i').scalar).to be(1) }
  end
end
