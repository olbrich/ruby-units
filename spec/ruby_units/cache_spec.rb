require File.dirname(__FILE__) + '/../spec_helper'

describe Unit::Cache do
  subject { Unit::Cache }
  let(:unit) { RubyUnits::Unit.new('1 m') }

  before(:each) do
    subject.clear
    subject.set('m', unit)
  end

  context '.clear' do
    it 'should clear the cache' do
      subject.clear
      expect(subject.get('m')).to be_nil
    end
  end

  context '.get' do
    it 'should retrieve values already in the cache' do
      expect(subject.get['m']).to eq(unit)
    end
  end

  context '.set' do
    it 'should put a unit into the cache' do
      subject.set('kg', RubyUnits::Unit.new('1 kg'))
      expect(subject.get['kg']).to eq(RubyUnits::Unit.new('1 kg'))
    end
  end
end
