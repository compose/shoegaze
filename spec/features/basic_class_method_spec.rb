require 'spec_helper'

class BasicClassMethod
  class << self
    def basic_class_method(arg1, arg2)
      raise "should never see this"
    end
  end
end

class FakeBasicClassMethod < Shoegaze::Mock
  mock BasicClassMethod

  implement_class_method :basic_class_method do
    scenario :good do
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

describe FakeBasicClassMethod do
  let!(:mock){ FakeBasicClassMethod.proxy }

  describe "good scenario" do
    let!(:args){ [:wool, :cotton] }

    before do
      FakeBasicClassMethod.class_call(:basic_class_method).with(*args).yields(:good)
    end

    it "runs the :good scenario datasource" do
      expect(mock.basic_class_method(*args)).to eq(:perfect_socks)
    end
  end

  describe "bad scenario" do
    let!(:args){ [:burlap, :fiberglass] }

    before do
      FakeBasicClassMethod.class_call(:basic_class_method).with(*args).yields(:bad)
    end

    it "runs the :bad scenario datasource" do
      expect(mock.basic_class_method(*args)).to eq(:terrible_socks)
    end
  end
end
