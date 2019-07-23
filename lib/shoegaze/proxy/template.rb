module Shoegaze
  module Proxy
    # Provides the basic 'template' for our anonymous proxy classes whose *only purpose* is to
    # delegate implementation method calls to the class and instance doubles.
    class Template
      class << self
        attr_accessor :class_double
        attr_accessor :instance_double

        def method_missing(method, *args)
          # yeah, we are abusing re-use of rspec doubles
          class_double.instance_variable_set(:@__expired, false)

          default_scenario = class_double.default_scenario(method)

          return class_double.send(method, *args) if class_double.respond_to?(method)
          return default_scenario.call(*args) if default_scenario

          begin
            super
          rescue NoMethodError
            raise_no_implementation_error(method, class_double)
          end
        end

        private

        def raise_no_implementation_error(method, double)
          raise Shoegaze::Scenario::Orchestrator::NoImplementationError.new("#{self.name} either has no Shoegaze mock implementation or no scenario has been orchestrated for method :#{method}")
        end
      end

      def initialize(*args)
        # Mock argumented initialize method.
        # This allows shoegaze to mock class with a customized initializer.
      end

      def method_missing(method, *args)
        double = self.class.instance_double

        # yeah, we are abusing re-use of rspec doubles
        double.instance_variable_set(:@__expired, false)

        default_scenario = double.default_scenario(method)

        return double.send(method, *args) if double.respond_to?(method)
        return default_scenario.call(*args) if default_scenario

        begin
          super
        rescue NoMethodError
          self.class.raise_no_implementation_error(method, double)
        end
      end
    end
  end
end
