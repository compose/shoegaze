module Shoegaze
  class ScenarioOrchestrator
    include RSpec::Mocks::ExampleMethods

    def initialize(mock_class, mock_proxy, method_name)
      @_mock_class  = mock_class
      @_mock_proxy  = mock_proxy
      @_method_name = method_name
    end

    def with(*args)
      @_args = args
      self
    end

    def yields(scenario_name)
      scenario = @_mock_class.implementations[@_method_name].scenarios[scenario_name]

      allow_any_instance_of(@_mock_class).to receive(@_method_name).with(*@_args) do
        data = @_mock_class.instance_exec(*@_args, &scenario.to_proc)

        represent(data, scenario)
      end
    end

    private

    def represent(data, scenario)
      return data unless scenario.representer

      representer = scenario.representer.new(data)

      return representer unless scenario.represent_method

      representer.send(scenario.represent_method)
    end
  end
end
