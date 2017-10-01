require File.dirname(__FILE__) + '/../spec_helper'

describe "Unit::Definition('eV')" do
  subject do
    Unit::Definition.new('eV') do |ev|
      ev.aliases      = ['eV', 'electron-volt']
      ev.definition   = RubyUnits::Unit.new('1.602E-19 joule')
      ev.display_name = 'electron-volt'
    end
  end

  describe '#name' do
    subject { super().name }
    it { is_expected.to eq('<eV>') }
  end

  describe '#aliases' do
    subject { super().aliases }
    it { is_expected.to eq(%w[eV electron-volt]) }
  end

  describe '#scalar' do
    subject { super().scalar }
    it { is_expected.to eq(1.602E-19) }
  end

  describe '#numerator' do
    subject { super().numerator }
    it { is_expected.to include('<kilogram>', '<meter>', '<meter>') }
  end

  describe '#denominator' do
    subject { super().denominator }
    it { is_expected.to include('<second>', '<second>') }
  end

  describe '#display_name' do
    subject { super().display_name }
    it { is_expected.to eq('electron-volt') }
  end
end
