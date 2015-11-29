require_relative '../../../lib/ruby_units/definition/base'
require_relative '../../../lib/ruby_units/unit_system'

describe RubyUnits::Definition::Base do
  let(:proxy) do
    proxy = RubyUnits::UnitSystem::Proxy::Base.new('quton')
    proxy.instance_eval do
      aliases %w(qu quton qutons)
      kind :happiness
    end
    proxy
  end

  subject do
    RubyUnits::Definition::Base.new(proxy, :si)
  end

  its(:numerator) { is_expected.to eq %i(quton) }
  its(:denominator) { is_expected.to be_empty }
  its(:display_name) { is_expected.to eq 'qu' }
  its(:aliases) { is_expected.to eq Set.new(%w(qu quton qutons)) }
  its(:scalar) { is_expected.to eq 1 }
  its(:kind) { is_expected.to eq :happiness }
  its(:name) { is_expected.to eq :quton }
  its(:definition) { is_expected.to be_nil }

  it 'knows what unit systems it is defined in' do
    si_system = instance_double('RubyUnits::UnitSystem')
    expect(RubyUnits::UnitSystem).to receive(:registered).and_return(si: si_system)
    expect(subject.unit_system).to eq si_system
  end
end
