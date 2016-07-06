module Shoegaze
  class Implementation
    attr_reader :scenarios

    def initialize(mock_class, mock_double, scope, method_name, &block)
      @_mock_class  = mock_class
      @_mock_double = mock_double
      @_scope       = scope
      @_method_name = method_name
      @scenarios    = {}

      self.instance_eval(&block)
    end

    # Defines a named scenario for the implementation
    #
    # @param name [Symbol] name of the scenario
    # @param block [Block] Shoegaze::Scenario implementation expressed in a block
    # @return [Scenario] the created scenario
    #
    # example:
    #
    #   scenario :success do
    #     datasource do
    #       # ...
    #     end
    #   end
    #
    def scenario(scenario_name, &block)
      @scenarios[scenario_name] = Scenario.new(@_method_name, &block)
    end

    # Defines the default scenario for the implementation
    #
    # @param block [Block] Shoegaze::Scenario implementation expressed in a block
    # @return [Scenario] the created scenario
    #
    # example:
    #
    #   default do
    #     datasource do
    #       # ...
    #     end
    #   end
    #
    def default(&block)
      @scenarios[:default] = scenario = Scenario.new(@_method_name, &block)

      scenario_orchestrator = Scenario::Orchestrator.new(@_mock_class, @_mock_double, @_scope, @_method_name)

      # NOTE: we can't use RSpec mock methods here because :default is called outside of a
      # test scope. so we have added some :default_scenario* methods instead
      @_mock_double.add_default_scenario(@_method_name, proc do |*args|
        scenario_orchestrator.with(*args).execute_scenario(scenario)
      end)

      scenario
    end

    private

    def defining_method
      case @_scope
      when :class
        :define_singleton_method
      when :instance
        :define_method
      end
    end
  end
end
