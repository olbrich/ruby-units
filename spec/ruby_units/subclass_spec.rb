# frozen_string_literal: true

RSpec.describe 'Subclass' do
  subject(:subclass) { Class.new(RubyUnits::Unit) }

  it 'can be subclassed' do
    expect(subclass).to be < RubyUnits::Unit
  end

  it 'can be instantiated' do
    expect(subclass.new('1 m')).to be_a(RubyUnits::Unit)
  end

  it 'compares to the parent class' do
    expect(subclass.new('1 m')).to eq(RubyUnits::Unit.new('1 m'))
  end

  it 'can be added to another subclass instance' do
    expect(subclass.new('1 m') + subclass.new('1 m')).to eq(RubyUnits::Unit.new('2 m'))
  end

  it 'returns a subclass object when added to another instance of a subclass' do
    expect(subclass.new('1 m') + subclass.new('1 m')).to be_an_instance_of(subclass)
  end

  it 'returns an instance of the parent class when added to another instance of a subclass' do
    expect(RubyUnits::Unit.new('1 m') + subclass.new('1 m')).to be_an_instance_of(RubyUnits::Unit)
  end

  it 'returns an instance of the subclass when added to an instance of the parent class' do
    expect(subclass.new('1 m') + RubyUnits::Unit.new('1 m')).to be_an_instance_of(subclass)
  end
end
