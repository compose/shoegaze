require 'spec_helper'

class NestedInstanceMethodSubclass
  def another_instance_method(arg1, arg2)
    raise "should never see this"
  end
end

class NestedInstanceMethod
  def nested_instance_method(arg1, arg2)
    return NestedInstanceMethodSubclass.new(*args)
  end
end

class FakeNestedInstanceMethod < Shoegaze::Mock
  mock "NestedInstanceMethod"

  implement_instance_method :nested_instance_method do
    scenario :good do
      datasource do |arg1, arg2|
        implement :another_instance_method do
          default do
            datasource do |subarg1, subarg2|
              :perfect_socks
            end
          end
        end
      end
    end
  end
end

describe FakeNestedInstanceMethod do
  let!(:mock){ FakeNestedInstanceMethod.proxy }

  describe "good scenario" do
    let!(:args){ [:wool, :cotton] }

    before do
      FakeNestedInstanceMethod.instance_call(:nested_instance_method).with(*args).yields(:good)
    end

    it "runs the :good scenario datasource and chains into its nested scenario" do
      expect(mock.new.nested_instance_method(*args).another_instance_method).to eq(:perfect_socks)
    end
  end
end
