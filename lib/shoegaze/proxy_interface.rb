module Shoegaze
  module ProxyInterface
    include RSpec::Mocks::ExampleMethods

    attr_reader :implementations

    def implement_class_method(method_name, &block)
      implementations[:class][method_name] = Implementation.new(self, :class, method_name, &block)
    end

    def implement_instance_method(method_name, &block)
      implementations[:instance][method_name] = Implementation.new(self, :instance, method_name, &block)
    end

    alias_method :implement, :implement_instance_method

    def instance_call(method_name)
      ScenarioOrchestrator.new(self, :instance, method_name)
    end

    def class_call(method_name)
      ScenarioOrchestrator.new(self, :class, method_name)
    end

    alias_method :calling, :instance_call
  end
end
