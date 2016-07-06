require 'spec_helper'

class ClassDefaultScenario
  class << self
    def basic_class_method(arg1, arg2)
      raise "should never see this"
    end
  end
end

class FakeClassDefaultScenario < Shoegaze::Mock
  mock ClassDefaultScenario

  implement_class_method :basic_class_method do
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

describe FakeClassDefaultScenario do
  let!(:mock){ FakeClassDefaultScenario.proxy }

  describe "with no specific scenario orchestrated and a default scenario implemented" do
    let!(:args){ [:wool, :cotton] }

    it "the :default scenario is run" do
      expect(mock.basic_class_method(*args)).to eq(:perfect_socks)
    end
  end

  describe "with the bad scenario orchestrated" do
    let!(:args){ [:burlap, :fiberglass] }

    before do
      FakeClassDefaultScenario.class_call(:basic_class_method).with(*args).yields(:bad)
    end

    it "runs the :bad scenario datasource" do
      expect(mock.basic_class_method(*args)).to eq(:terrible_socks)
    end
  end
end
