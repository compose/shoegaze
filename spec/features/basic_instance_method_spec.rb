require 'spec_helper'

class BasicInstanceMethod
  def basic_instance_method(arg1, arg2)
    raise "should never see this"
  end
end

class FakeBasicInstanceMethod < Shoegaze::Mock
  mock BasicInstanceMethod

  implement_instance_method :basic_instance_method do
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

describe FakeBasicInstanceMethod do
  let!(:mock){ FakeBasicInstanceMethod.proxy }

  describe "good scenario" do
    let!(:args){ [:wool, :cotton] }

    before do
      FakeBasicInstanceMethod.instance_call(:basic_instance_method).with(*args).yields(:good)
    end

    it "runs the :good scenario datasource" do
      expect(mock.new.basic_instance_method(*args)).to eq(:perfect_socks)
    end
  end

  describe "bad scenario" do
    let!(:args){ [:burlap, :fiberglass] }

    before do
      FakeBasicInstanceMethod.instance_call(:basic_instance_method).with(*args).yields(:bad)
    end

    it "runs the :bad scenario datasource" do
      expect(mock.new.basic_instance_method(*args)).to eq(:terrible_socks)
    end
  end
end
