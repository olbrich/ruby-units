require_relative "spec_helper"

module RubyUnits

  describe Unit::Cache do
    subject { Unit::Cache }
    let(:unit) { Unit.new('1 m') }

    before(:each) do
      subject.clear
      subject.set("m", unit)
    end

    context ".clear" do    
      it "should clear the cache" do
        subject.clear
        expect(subject.get('m')).to be_nil
      end
    end

    context ".get" do
      it "should retrieve values already in the cache" do
        expect(subject.get['m']).to eq(unit)
      end
    end

    context ".set" do
      it "should put a unit into the cache" do
        subject.set('kg', Unit.new('1 kg'))
        expect(subject.get['kg']).to eq(Unit.new('1 kg'))
      end
    end
  end

end
