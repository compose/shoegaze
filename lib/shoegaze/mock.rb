module Shoegaze
  class Mock
    extend RSpec::Mocks::ExampleMethods

    class InvalidNamespaceError < StandardError; end

    class << self
      attr_reader :implementations

      def mock(class_name)
        @_class_name = class_name
        @_mock_instance_proxy = instance_double(klass.to_s)
        @_mock_class_proxy = class_double(klass.to_s)

        @implementations = {class: {}, instance: {}}
      end

      def implement_class_method(method_name, &block)
        @implementations[:class][method_name] = Implementation.new(self, :class, method_name, &block)
      end

      def implement_instance_method(method_name, &block)
        @implementations[:instance][method_name] = Implementation.new(self, :instance, method_name, &block)
      end

      alias_method :implement, :implement_instance_method

      def instance_call(method_name)
        ScenarioOrchestrator.new(self, :instance, method_name)
      end

      def class_call(method_name)
        ScenarioOrchestrator.new(self, :class, method_name)
      end

      alias_method :calling, :instance_call

      private

      def klass
        @klass = @_class_name.constantize
      end
    end
  end
end
