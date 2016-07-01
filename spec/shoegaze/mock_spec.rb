require 'spec_helper'

describe Shoegaze::Mock do
  include SpecHelpers

  subject{ Shoegaze::Mock }

  describe "included modules" do
    it "includes Proxy::Interface" do
      expect(subject).to respond_to :implement_class_method
    end
  end

  describe "#self.mock" do
    let!(:test_class){ random_named_class }
    let!(:mocked){ subject.mock(test_class.name) }

    it "sets empty implementations" do
      expect(Shoegaze::Mock.implementations).to eq({class: {}, instance: {}})
    end

    it "creates class and instance doubles of the provided class" do
      # hork
      expect(
        Shoegaze::Mock.instance_variable_get(:@mock_class_double).
          instance_variable_get(:@doubled_module).
          instance_variable_get(:@const_name)
      ).to eq(test_class.name)

      expect(
        Shoegaze::Mock.instance_variable_get(:@mock_instance_double).
          instance_variable_get(:@doubled_module).
          instance_variable_get(:@const_name)
      ).to eq(test_class.name)
    end

    it "returns a mock proxy anonymous class" do
      expect(mocked).to respond_to :class_double
      expect(mocked).to respond_to :instance_double
    end
  end
end
