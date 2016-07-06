require 'spec_helper'

class InstanceDefaultScenario
  def basic_instance_method(arg1, arg2)
    raise "should never see this"
  end
end

class FakeInstanceDefaultScenario < Shoegaze::Mock
  mock InstanceDefaultScenario

  implement_instance_method :basic_instance_method do
    default do
      datasource do |arg1, arg2|
        :perfect_socks
      end
    end

    scenario :bad do
      datasource do |arg1, arg2|
        :terrible_socks
      end
    end
  end
end

describe FakeInstanceDefaultScenario do
  let!(:mock){ FakeInstanceDefaultScenario.proxy }

  describe "with no specific scenario orchestrated and a default scenario implemented" do
    let!(:args){ [:wool, :cotton] }

    it "the :default scenario is run" do
      instance = mock.new

      expect(instance.basic_instance_method(*args)).to eq(:perfect_socks)
    end
  end

  describe "with the bad scenario orchestrated" do
    let!(:args){ [:burlap, :fiberglass] }

    before do
      FakeInstanceDefaultScenario.instance_call(:basic_instance_method).with(*args).yields(:bad)
    end

    it "runs the :bad scenario datasource" do
      expect(mock.new.basic_instance_method(*args)).to eq(:terrible_socks)
    end
  end
end
