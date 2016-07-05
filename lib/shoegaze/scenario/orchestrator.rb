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

      def with(*args)
        @_args = args
        self
      end

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
      end

      def execute_scenario(scenario)
        data = self.instance_exec(*@_args, &scenario.to_proc)

        represent(data, scenario)
      end

      # TODO: can we use delegate and alias for this?
      # basically all implementations from here on are chained and will be class method
      # calls
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
