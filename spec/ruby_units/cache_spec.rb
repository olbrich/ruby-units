RSpec.describe RubyUnits::Cache do
  subject(:cache) { described_class.new }

  let(:unit) { RubyUnits::Unit.new('1 m') }

  before do
    cache.clear
    cache.set('m', unit)
  end

  describe '.clear' do
    it 'clears the cache' do
      cache.clear
      expect(cache.get('m')).to be_nil
    end
  end

  describe '.get' do
    it 'retrieves values already in the cache' do
      expect(cache.get('m')).to eq(unit)
    end
  end

  describe '.set' do
    it 'puts a unit into the cache' do
      cache.set('kg', RubyUnits::Unit.new('1 kg'))
      expect(cache.get('kg')).to eq(RubyUnits::Unit.new('1 kg'))
    end
  end
end
