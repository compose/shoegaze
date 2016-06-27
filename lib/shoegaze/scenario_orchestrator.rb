module Shoegaze
  class ScenarioOrchestrator
    include RSpec::Mocks::ExampleMethods

    class NoImplementationError < StandardError; end

    def initialize(mock_class, scope, method_name)
      @_scope       = scope
      @_mock_class  = mock_class
      @_method_name = method_name
    end

    def with(*args)
      @_args = args
      self
    end

    def yields(scenario_name)
      scenario = @_mock_class.implementations[@_scope][@_method_name].scenarios[scenario_name]

      unless scenario
        raise NoImplementationError.new(
                "#{@_mock_class} has no implementation for scenario :#{scenario_name} of the #{@_scope} method :#{@_method_name}."
              )
      end

      args = @_args || [anything]
      send(allowance, @_mock_class).to receive(@_method_name).with(*args) do
        execute_scenario(scenario)
      end
    end

    def execute_scenario(scenario)
      data = @_mock_class.instance_exec(*@_args, &scenario.to_proc)

      represent(data, scenario)
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
  end
end
