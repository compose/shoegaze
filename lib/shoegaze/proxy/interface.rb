module Shoegaze
  module Proxy
    # A common interface module for defining mock implementations, scenarios, and driving
    # the implementations/scenarios from the test interface.
    module Interface
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          extend RSpec::Mocks::ExampleMethods

          class << self
            attr_reader :implementations
          end
        end
      end

      module ClassMethods
        # Defines a named Shoegaze implementation for a class method.
        #
        # @param method_name [Symbol] Symbol name for the class method that is being implemented
        # @param block [Block] Shoegaze::Implementation expressed in a block
        # @return [Shoegaze::Implementation] The created implementation.
        #
        # example:
        #
        #   class FakeThing < Shoegaze::Mock
        #     mock RealThing
        #
        #     implement_class_method :find_significant_other do
        #       default do
        #         datasource do
        #           :ohhai
        #         end
        #       end
        #     end
        #   end
        #
        # example usage:
        #
        #   $ FakeThing.proxy.find_significant_other
        #   :ohhai
        def implement_class_method(method_name, &block)
          implementations[:class][method_name] = Implementation.new(self, @mock_class_double, :class, method_name, &block)
        end

        # Defines a named Shoegaze implementation for a instance method.
        #
        # @param method_name [Symbol] Symbol name for the instance method that is being implemented
        # @param block [Block] Shoegaze::Implementation expressed in a block
        # @return [Shoegaze::Implementation] The created implementation.
        #
        # example:
        #
        #   class FakeThing < Shoegaze::Mock
        #     mock RealThing
        #
        #     implement_instance_method :find_significant_other do
        #       default do
        #         datasource do
        #           :ohhai
        #         end
        #       end
        #     end
        #   end
        #
        # example usage:
        #
        #   $ FakeThing.proxy.new.find_significant_other
        #   :ohhai
        def implement_instance_method(method_name, &block)
          implementations[:instance][method_name] = Implementation.new(self, @mock_instance_double, :instance, method_name, &block)
        end

        alias_method :implement, :implement_instance_method

        # Defines a Scenario::Orchestrator for the method name, which is used to trigger
        # particular scenarios when the class method is called on the mock proxy.
        #
        # @param method_name [Symbol] Symbol name for the class method that is being orchestrated.
        # @return [Shoegaze::Orchestrator] The created Shoegaze orchestration.
        #
        # example:
        #
        #   class FakeThing < Shoegaze::Mock
        #     mock RealThing
        #
        #     implement_instance_method :find_significant_other do
        #       scenario :success do
        #         datasource do
        #           :ohhai
        #         end
        #       end
        #     end
        #   end
        #
        # example usage:
        #
        #   $ FakeThing.proxy.class_call(:find_significant_other).with(:wow).yields(:success)
        #   $ FakeThing.proxy.find_significant_other(:wow)
        #   :ohhai
        #
        def class_call(method_name)
          Scenario::Orchestrator.new(self, @mock_class_double, :class, method_name)
        end

        # Defines a Scenario::Orchestrator for the method name, which is used to trigger
        # particular scenarios when the instance method is called on the mock proxy.
        #
        # @param method_name [Symbol] Symbol name for the instance method that is being orchestrated.
        # @return [Shoegaze::Orchestrator] The created Shoegaze orchestration.
        #
        # example:
        #
        #   class FakeThing < Shoegaze::Mock
        #     mock RealThing
        #
        #     implement_instance_method :find_significant_other do
        #       scenario :success do
        #         datasource do
        #           :ohhai
        #         end
        #       end
        #     end
        #   end
        #
        # example usage:
        #
        #   $ FakeThing.proxy.instance_call(:find_significant_other).with(:wow).yields(:success)
        #   $ FakeThing.proxy.new.find_significant_other(:wow)
        #   :ohhai
        #
        def instance_call(method_name)
          Scenario::Orchestrator.new(self, @mock_instance_double, :instance, method_name)
        end

        alias_method :calling, :instance_call

        # Creates an anonymous class inherited from Shoegaze::Proxy that delegates method
        # calls to the proxy instance and class doubles. This is the stand-in for your
        # real implementation.
        #
        # @return [Class.new(Shoegaze::Proxy)] A Shoegaze proxy class stand-in for the real implementation.
        def proxy
          @proxy ||= Shoegaze::Proxy.new(@mock_class_double, @mock_instance_double)
        end

        private

        # Rspec doubles don't let us use them outside of tests, which is pretty annoying
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
