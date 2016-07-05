require 'spec_helper'

describe Shoegaze::Scenario::Orchestrator do
  include SpecHelpers

  let!(:scope){ :instance }
  let!(:mock_class){ double }
  let!(:mock_double){ double }
  let!(:method_name){ :techno_viking }
  let!(:scenario_orchestrator){ Shoegaze::Scenario::Orchestrator.new(mock_class, mock_double, scope, method_name) }

  describe "#initialize" do
    it "sets instance variables" do
      expect(scenario_orchestrator.instance_variable_get(:@_scope)).to eq(scope)
      expect(scenario_orchestrator.instance_variable_get(:@_mock_class)).to eq(mock_class)
      expect(scenario_orchestrator.instance_variable_get(:@_mock_double)).to eq(mock_double)
      expect(scenario_orchestrator.instance_variable_get(:@_method_name)).to eq(method_name)
    end
  end

  describe "#with" do
    let!(:args){ [:boy, :howdy] }

    it "sets the args and returns self" do
      expect(scenario_orchestrator.with(*args)).to eq(scenario_orchestrator)
      expect(scenario_orchestrator.instance_variable_get(:@_args)).to eq(args)
    end
  end

  describe "#yields" do
    let!(:test_class){
      random_named_class do
        def self.techno_viking(arg1, arg2)
        end

        def techno_viking(arg1, arg2)
        end
      end
    }
    let!(:args){ [:one, :two] }
    let!(:scenario_name){ :invisible_pickles }
    let!(:fake_scenario){ double }
    let!(:fake_implementation){ double(scenarios: {invisible_pickles: fake_scenario}) }

    describe "for an instance" do
      let!(:mock_double){ instance_double(test_class.name) }
      let!(:scenario_orchestrator){ Shoegaze::Scenario::Orchestrator.new(mock_class, mock_double, :instance, method_name) }

      describe "with a scenario" do
        before :each do
          allow(mock_class).to receive(:implementations).and_return(
                                 {instance: {techno_viking: fake_implementation}}
                               )
        end

        it "sets up the specific scenario with rspec" do
          scenario_orchestrator.with(*args).yields(scenario_name)

          expect(scenario_orchestrator).to receive(:execute_scenario).with(fake_scenario)
          mock_double.send(:techno_viking, *args)

          expect{
            mock_double.send(:techno_viking, :wrong, :args)
          }.to raise_exception RSpec::Mocks::MockExpectationError
        end
      end

      describe "for a class" do
        let!(:mock_double){ class_double(test_class.name) }
        let!(:scenario_orchestrator){ Shoegaze::Scenario::Orchestrator.new(mock_class, mock_double, :class, method_name) }

        describe "with a scenario" do
          before :each do
            allow(mock_class).to receive(:implementations).and_return(
                                   {class: {techno_viking: fake_implementation}}
                                 )
          end

          it "sets up the scenario with rspec" do
            scenario_orchestrator.with(*args).yields(scenario_name)

            expect(scenario_orchestrator).to receive(:execute_scenario).with(fake_scenario)
            mock_double.send(:techno_viking, *args)

            expect{
              mock_double.send(:techno_viking, :wrong, :args)
            }.to raise_exception RSpec::Mocks::MockExpectationError
          end
        end
      end
    end

    describe "with no scenario" do
      let!(:scenario_orchestrator){ Shoegaze::Scenario::Orchestrator.new(mock_class, mock_double, :class, method_name) }
      let!(:fake_implementation){ double(scenarios: {}) }

      before :each do
        allow(mock_class).to receive(:implementations).and_return(
                               {class: {techno_viking: fake_implementation}}
                             )
      end

      it "raises a NoImplementationError" do
        expect{ scenario_orchestrator.with(*args).yields(scenario_name) }.to raise_exception Shoegaze::Scenario::Orchestrator::NoImplementationError
      end
    end
  end

  describe "#execute_scenario" do
    let!(:test_block){ proc { } }
    let!(:fake_scenario){ double }
    let!(:fake_args){ [:one, :two] }

    before :each do
      scenario_orchestrator.with(*fake_args)

      # FIXME: this is a big fugly
      allow(fake_scenario).to receive(:to_proc).
                                and_return(
                                  proc do |*args|
                                    raise "bogus" unless args == [:one, :two]

                                    whodunnit

                                    :some_data
                                  end
                                )
    end

    it "runs the block with the args and passes the result to #represent" do
      expect(scenario_orchestrator).to receive(:whodunnit)
      expect(scenario_orchestrator).to receive(:represent).with(:some_data, fake_scenario)

      scenario_orchestrator.execute_scenario(fake_scenario)
    end
  end

  describe "#implement" do
    let!(:proxy_interface){ scenario_orchestrator.send(:proxy_interface) }
    let!(:test_block){ proc { } }

    it "calls #implement_class_method on the implementation proxy and returns the proxy" do
      expect(proxy_interface).to receive(:implement_class_method).with(method_name, &test_block)
      expect(scenario_orchestrator.implement(method_name, &test_block)).to eq(proxy_interface.proxy)
    end
  end
end
