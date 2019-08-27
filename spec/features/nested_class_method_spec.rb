require 'spec_helper'

class NestedClassMethodSubclass
  def self.another_class_method(arg1, arg2)
    raise "should never see this"
  end
end

class NestedClassMethod
  def self.nested_class_method(arg1, arg2)
    return NestedClassMethodSubclass.new(*args)
  end
end

class FakeNestedClassMethod < Shoegaze::Mock
  mock "NestedClassMethod"

  implement_class_method :nested_class_method do
    scenario :good do
      datasource do |arg1, arg2|
        implement :another_method do
          default do
            datasource do
              :perfect_socks
            end
          end
        end
      end
    end
  end
end

describe FakeNestedClassMethod do
  let!(:mock){ FakeNestedClassMethod.proxy }

  describe "good scenario" do
    let!(:args){ [:wool, :cotton] }

    before do
      FakeNestedClassMethod.class_call(:nested_class_method).with(*args).yields(:good)
    end

    it "runs the :good scenario datasource and chains into its nested scenario" do
      expect(mock.nested_class_method(*args).another_method).to eq(:perfect_socks)
    end
  end
end
