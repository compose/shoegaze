module Shoegaze
  class Scenario
    class Orchestrator
      include RSpec::Mocks::ExampleMethods

      class NoImplementationError < StandardError; end

      def initialize(mock_class, mock_double, scope, method_name)
        @_scope       = scope
        @_mock_class  = mock_class
        @_mock_double = mock_double
        @_method_name = method_name
      end

      # Specifies the arguments to which this scenario will be scoped.
      #
      # @param args [*Arguments] any number of free-form arguments
      # @return [Shoegaze::Scenario::Orchestrator] returns the orchestrator `self` for chainability
      #
      def with(*args)
        @_args = args
        self
      end

      # Specifies the scenario for the implementation that will be triggered when this method is
      # called with the specified scope (arguments, etc).
      #
      # @param scenario_name [Symbol] The name of the scenario to trigger.
      # @return [Shoegaze::Scenario::Orchestrator] returns the orchestrator `self` for chainability
      #
      def yields(scenario_name)
        implementation = @_mock_class.implementations[@_scope][@_method_name]

        scenario = begin
                     implementation.scenarios[scenario_name]
                   rescue NoMethodError
                   end

        unless scenario
          raise NoImplementationError.new(
                  "#{@_mock_class} has no implementation for scenario :#{scenario_name} of the #{@_scope} method :#{@_method_name}."
                )
        end

        args = @_args || [anything]

        # yeah, we are abusing re-use of rspec doubles
        @_mock_double.instance_variable_set(:@__expired, false)

        send(:allow, @_mock_double).to receive(@_method_name).with(*args) do
          execute_scenario(scenario)
        end

        self
      end

      # Executes the specified implementation scenario.
      #
      # @param scenario_name [Symbol] The name of the scenario to run.
      # @return [Misc] returns the represented result of the scenario
      #
      def execute_scenario(scenario)
        data = self.instance_exec(*@_args, &scenario.to_proc)

        represent(data, scenario)
      end

      # Specifies a sub-implementation proxy interface used for recursive chaining of
      # implementations. Think of it as a recursable Shoegaze::Mock.implement_class_method.
      # All sub-implementations are internally implemented as class methods for simplicity.
      #
      # @param method_name [Symbol] The name of the nested method to implement
      # @return [Class.new(Shoegaze::Proxy)] A Shoegaze proxy for next layer of the implementation.
      #
      # example:
      #
      #   class Fake < Shoegaze::Mock
      #     mock Real
      #
      #     implement :accounts do # top-level Shoegaze::Mock interface
      #       scenario :success do
      #         datasource do
      #           implement :create do # _this method_
      #             default do
      #               datasource do
      #                 implement :even_more_things # _this method again_
      #                   default do
      #                     datasource do |params|
      #                       :popcorn
      #                     end
      #                   end
      #                 end
      #               end
      #             end
      #           end
      #         end
      #       end
      #     end
      #   end
      #
      #   $ Fake.accounts.create.even_more_things
      #   :popcorn
      #
      def implement(method_name, &block)
        proxy_interface.implement_class_method(method_name, &block)
        proxy_interface.proxy
      end

      private

      def allowance
        case @_scope
        when :instance
          :allow_any_instance_of
        when :class
          :allow
        end
      end

      def represent(data, scenario)
        return data unless scenario.representer

        representer = scenario.representer.new(data)
        return representer unless scenario.represent_method

        representer.send(scenario.represent_method)
      end

      # creates a new mocking context for the nested method call
      # see Shoegaze::Scenario::Mock
      def proxy_interface
        return @_proxy_interface if @_proxy_interface

        @_proxy_interface = Class.new(Scenario::Mock)
        @_proxy_interface.mock
        @_proxy_interface
      end
    end
  end
end
