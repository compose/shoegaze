module Shoegaze
  class Implementation
    attr_reader :scenarios

    def initialize(method_name, &block)
      @_method_name = method_name
      @scenarios    = {}

      self.instance_eval(&block)
    end

    def scenario(scenario_name, &block)
      @scenarios[scenario_name] = Scenario.new(@_method_name, &block)
    end
  end
end
