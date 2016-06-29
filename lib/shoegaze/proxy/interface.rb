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

        def instance_call(method_name)
          ScenarioOrchestrator.new(self, @mock_instance_double, :instance, method_name)
        end

        def class_call(method_name)
          ScenarioOrchestrator.new(self, @mock_class_double, :class, method_name)
        end

        alias_method :calling, :instance_call

        def proxy
          @proxy ||= Shoegaze::Proxy.new(@mock_class_double, @mock_instance_double)
        end
      end
    end
  end
end
