require_relative '../../../lib/ruby_units/definition/prefix'
require_relative '../../../lib/ruby_units/unit_system'

describe RubyUnits::Definition::Prefix do
  let(:proxy) do
    proxy = RubyUnits::UnitSystem::Proxy.new('fifth')
    proxy.instance_eval do
      aliases %w(fifth)
      scalar Rational(1, 5)
    end
    proxy
  end

  subject do
    RubyUnits::Definition::Prefix.new(proxy, :si)
  end

  its(:numerator) { is_expected.to be_empty }
  its(:denominator) { is_expected.to be_empty }
  its(:display_name) { is_expected.to eq 'fifth' }
  its(:aliases) { is_expected.to eq Set.new(%w(fifth)) }
  its(:scalar) { is_expected.to eq Rational(1, 5) }
  its(:kind) { is_expected.to eq :prefix }
  its(:name) { is_expected.to eq :fifth }
  its(:definition) { is_expected.to be_nil }

  it 'knows what unit systems it is defined in' do
    si_system = instance_double('RubyUnits::UnitSystem')
    expect(RubyUnits::UnitSystem).to receive(:registered).and_return(si: si_system)
    expect(subject.unit_system).to eq si_system
  end
end
