module Shoegaze
  class Mock
    extend RSpec::Mocks::ExampleMethods

    class << self
      attr_reader :implementations

      def mock(klass)
        @_mock_proxy = instance_double(klass.name)
        @implementations = {}
      end

      def implement(method_name, &block)
        @implementations[method_name] = Implementation.new(method_name, &block)
      end

      def calling(method_name)
        ScenarioOrchestrator.new(self, @_mock_proxy, method_name)
      end
    end
  end
end
