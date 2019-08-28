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
      # example:
      #
      #   FakeThing.proxy.calling(:find_cows).with(123, 456).yields(:success)
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
      # example:
      #
      #   FakeThing.proxy.calling(:find_cows).with(123, 456).yields(:success)
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

        # yeah, we are abusing re-use of rspec doubles
        @_mock_double.instance_variable_set(:@__expired, false)

        args = @_args

        if @_args.nil?
          args = [anything]

          # also allow no args if no args are specified
          send(:allow, @_mock_double).to receive(@_method_name) do
            execute_scenario(scenario)
          end
        end

        send(
          :allow,
          @_mock_double
        ).to receive(@_method_name).with(*args) do |*_args, &datasource_block|
          execute_scenario(scenario, &datasource_block)
        end

        self
      end

      # Executes the specified implementation scenario.
      #
      # @param scenario_name [Symbol] The name of the scenario to run.
      # @yield [datasource_result] yields the result of the provided datasource block
      # @return [Misc] returns the represented result of the scenario
      #
      def execute_scenario(scenario, &datasource_block)
        # we do this crazy dance because we want scenario.to_proc to be run in the context
        # of self (an orchestrator) in order to enable nesting, but we also want to be
        # able to pass in a block. instance_exec would solve the context problem but
        # doesn't enable the passing of the block while simply calling the method would
        # allow passing the block but not changing the context.
        self.define_singleton_method :bound_proc, &scenario.to_proc
        data = self.bound_proc(*@_args, &datasource_block)

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
      #     mock "Real"
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
