# a common interface module for defining mock implementations, scenarios, and driving the
# implementations/scenarios from the test interface
module Shoegaze
  module Proxy
    module Interface
      extend ActiveSupport::Concern

      included do
        extend RSpec::Mocks::ExampleMethods

        class << self
          attr_reader :implementations
        end
      end

      class_methods do
        def implement_class_method(method_name, &block)
          implementations[:class][method_name] = Implementation.new(self, @mock_class_double, :class, method_name, &block)
        end

        def implement_instance_method(method_name, &block)
          implementations[:instance][method_name] = Implementation.new(self, @mock_instance_double, :instance, method_name, &block)
        end

        alias_method :implement, :implement_instance_method

        def class_call(method_name)
          Scenario::Orchestrator.new(self, @mock_class_double, :class, method_name)
        end

        def instance_call(method_name)
          Scenario::Orchestrator.new(self, @mock_instance_double, :instance, method_name)
        end

        alias_method :calling, :instance_call

        def proxy
          @proxy ||= Shoegaze::Proxy.new(@mock_class_double, @mock_instance_double)
        end

        # rspec doubles don't let us use them outside of tests, which is pretty annoying
        # because the 'default' scenario method needs to set up a scenario outside of the
        # testing scope. combine that with how rspec also overrides respond_to? and you
        # end up with a lovely hack like this
        def extend_double_with_extra_methods(double)
          double.instance_eval do
            @default_scenarios = {}

            def add_default_scenario(method_name, implementation)
              @default_scenarios[method_name] = implementation
            end

            def default_scenario(method_name)
              @default_scenarios[method_name]
            end
          end
        end
      end
    end
  end
end
