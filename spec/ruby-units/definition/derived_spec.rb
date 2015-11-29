require_relative '../../../lib/ruby_units/definition/derived'
require_relative '../../../lib/ruby_units/unit_system'
require 'ostruct'

describe RubyUnits::Definition::Derived do
  let(:proxy) do
    proxy = RubyUnits::UnitSystem::Proxy::Derived.new('Altman')
    proxy.instance_eval do
      aliases %w(Am Altmans)
      definition do
        OpenStruct.new(
          kind: :complexity,
          scalar: 1_000,
          numerator: %i(wtf),
          denominator: %i(second)
        )
      end
    end
    proxy
  end

  subject do
    described_class.new(proxy, :si)
  end

  its(:numerator) { is_expected.to eq %i(wtf) }
  its(:denominator) { is_expected.to eq %i(second) }
  its(:display_name) { is_expected.to eq 'Am' }
  its(:aliases) { is_expected.to eq Set.new(%w(Am Altman Altmans)) }
  its(:scalar) { is_expected.to eq 1_000 }
  its(:kind) { is_expected.to eq :complexity }
  its(:name) { is_expected.to eq :Altman }
  its(:definition) { is_expected.to_not be_nil }

  it 'knows what unit systems it is defined in' do
    si_system = instance_double('RubyUnits::UnitSystem')
    expect(RubyUnits::UnitSystem).to receive(:registered).and_return(si: si_system)
    expect(subject.unit_system).to eq si_system
  end
end
