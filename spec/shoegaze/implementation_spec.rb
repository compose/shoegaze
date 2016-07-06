require 'spec_helper'

describe Shoegaze::Implementation do
  include ImplementationSpecHelpers

  let!(:subject){ Shoegaze::Implementation }
  let!(:mock_class){ double }

  let!(:mock_double) do
    mock_double = double

    Shoegaze::Mock.send(:extend_double_with_extra_methods, mock_double)
    mock_double
  end

  let!(:scope){ :instance }
  let!(:method_name){ :bicycle }
  let!(:implementation){ subject.new(mock_class, mock_double, scope, method_name){} }

  describe "#initialize" do
    describe "instance variables" do
      it "are assigned" do
        expect(implementation.instance_variable_get(:@_mock_class)).to eq(mock_class)
        expect(implementation.instance_variable_get(:@_mock_double)).to eq(mock_double)
        expect(implementation.instance_variable_get(:@_scope)).to eq(scope)
        expect(implementation.instance_variable_get(:@_method_name)).to eq(method_name)
        expect(implementation.instance_variable_get(:@scenarios)).to eq({})
      end
    end

    describe "block" do
      it "is called in the scope of the implementation instance" do
        expect_any_instance_of(subject).to receive(:booyah)
        subject.new(mock_class, mock_double, scope, method_name){ booyah }
      end
    end
  end

  describe "#scenario" do
    let!(:fake_block){ proc { } }
    let!(:fake_scenario){ double }

    it "creates a Scenario with the method name and the block, keyed as the scenario name within scenarios" do
      expect(Shoegaze::Scenario).to receive(:new).with(method_name) do |name, &block|
        expect(block).to eq(fake_block)
        expect(name).to eq(method_name)

        fake_scenario
      end

      implementation.scenario(:dude_wheres_my_car, &fake_block)

      scenario = implementation.scenarios[:dude_wheres_my_car]
      expect(scenario).to eq(fake_scenario)
    end
  end

  describe "#default" do
    let!(:fake_block){ proc { } }
    let!(:fake_scenario){ double }
    let!(:fake_scenario_orchestrator){ double }
    let!(:fake_method_args){ ["chainring", "braze-on"] }

    before :each do
      allow(mock_double).to receive(:define_method)
      allow(Shoegaze::Scenario).to receive(:new).with(method_name).and_return(fake_scenario)
    end

    it "creates a Scenario with the method name and the block, keyed as :default within scenarios" do
      expect(Shoegaze::Scenario).to receive(:new).with(method_name) do |name, &block|
        expect(block).to eq(fake_block)
        expect(name).to eq(method_name)

        fake_scenario
      end

      implementation.default(&fake_block)

      scenario = implementation.scenarios[:default]
      expect(scenario).to eq(fake_scenario)
    end

    describe "with an :instance scope" do
      it "creates a named method that ultimately triggers :execute_scenario on a Scenario::Orchestrator" do
        expect_default_scenario_to_be_defined_for_scope(scope)
      end
    end

    describe "with a :class scope" do
      let!(:scope){ :class }

      it "creates a named singleton method that ultimately triggers :execute_scenario on a Scenario::Orchestrator" do
        expect_default_scenario_to_be_defined_for_scope(scope)
      end
    end
  end
end
