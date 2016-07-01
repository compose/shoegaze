require 'spec_helper'

describe Shoegaze::Proxy::Interface do
  include SpecHelpers

  let!(:test_class){ random_named_class }
  let!(:method_name){ :jiu_jitsu }
  let!(:test_block){ proc { } }
  let!(:mock_class_double){ double }
  let!(:mock_instance_double){ double }
  let!(:fake_implementation){ double }

  before do
    test_class.include(Shoegaze::Proxy::Interface)
    test_class.instance_variable_set(:@mock_class_double, mock_class_double)
    test_class.instance_variable_set(:@mock_instance_double, mock_instance_double)
    test_class.instance_variable_set(:@implementations, {class: {}, instance: {}})
  end

  describe "#self.implement_class_method" do
    it "stores a class implementation keyed by the method name" do
      expect(Shoegaze::Implementation).to receive(:new).with(test_class, mock_class_double, :class, method_name) do |*args, &block|
        expect(block).to eq(test_block)

        fake_implementation
      end

      test_class.implement_class_method(method_name, &test_block)
      expect(test_class.implementations[:class][method_name]).to eq(fake_implementation)
    end
  end

  describe "#self.implement_instance_method" do
    it "stores an instance implementation keyed by the method name" do
      expect(Shoegaze::Implementation).to receive(:new).with(test_class, mock_instance_double, :instance, method_name) do |*args, &block|
        expect(block).to eq(test_block)

        fake_implementation
      end

      test_class.implement_instance_method(method_name, &test_block)
      expect(test_class.implementations[:instance][method_name]).to eq(fake_implementation)
    end
  end

  describe "#self.implement" do
    it "is an alias of :implement_instance_method" do
      expect(test_class.method(:implement)).to eq(test_class.method(:implement_instance_method))
    end
  end

  describe "#self.instance_call" do
    let!(:fake_scenario_orchestrator){ double }

    it "returns an instance Scenario::Orchestrator" do
      expect(Shoegaze::Scenario::Orchestrator).to receive(:new).with(test_class, mock_instance_double, :instance, method_name).and_return(fake_scenario_orchestrator)
      expect(test_class.instance_call(method_name)).to eq(fake_scenario_orchestrator)
    end
  end

  describe "#self.class_call" do
    let!(:fake_scenario_orchestrator){ double }

    it "returns a class Scenario::Orchestrator" do
      expect(Shoegaze::Scenario::Orchestrator).to receive(:new).with(test_class, mock_class_double, :class, method_name).and_return(fake_scenario_orchestrator)
      expect(test_class.class_call(method_name)).to eq(fake_scenario_orchestrator)
    end
  end

  describe "#self.calling" do
    it "is an alias to :instance_call" do
      expect(test_class.method(:calling)).to eq(test_class.method(:instance_call))
    end
  end

  describe "#proxy" do
    let!(:fake_proxy){ double }

    it "returns and caches a Shoegaze::Proxy" do
      expect(Shoegaze::Proxy).to receive(:new).with(mock_class_double, mock_instance_double).and_return(fake_proxy)
      expect(test_class.proxy).to eq(fake_proxy)

      # test caching
      allow(Shoegaze::Proxy).to receive(:new).with(mock_class_double, mock_instance_double).and_return(:should_not_see_this)
      expect(test_class.proxy).to eq(fake_proxy)
    end
  end
end
