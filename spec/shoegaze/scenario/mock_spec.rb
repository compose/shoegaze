require 'spec_helper'

describe Shoegaze::Scenario::Mock do
  include SpecHelpers

  subject{ Shoegaze::Scenario::Mock }

  describe "included modules" do
    it "includes Proxy::Interface" do
      expect(subject).to respond_to :implement_class_method
    end
  end

  describe "#self.mock" do
    let!(:mocked){ subject.mock }

    it "sets empty implementations" do
      expect(Shoegaze::Scenario::Mock.implementations).to eq({class: {}, instance: {}})
    end

    it "creates class and instance doubles" do
      expect(Shoegaze::Scenario::Mock.instance_variable_get(:@mock_class_double)).to be_a RSpec::Mocks::Double
      expect(Shoegaze::Scenario::Mock.instance_variable_get(:@mock_instance_double)).to be_a RSpec::Mocks::Double
    end

    it "returns a mock proxy anonymous class" do
      expect(mocked).to respond_to :class_double
      expect(mocked).to respond_to :instance_double
    end
  end
end
