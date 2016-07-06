# provides the basic 'template' for our anonymous proxy classes whose *only purpose* is to
# delegate implementation method calls to the class and instance doubles
module Shoegaze
  module Proxy
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

          super
        end
      end

      def method_missing(method, *args)
        double = self.class.instance_double

        # yeah, we are abusing re-use of rspec doubles
        double.instance_variable_set(:@__expired, false)

        default_scenario = double.default_scenario(method)

        return double.send(method, *args) if double.respond_to?(method)
        return default_scenario.call(*args) if default_scenario

        super
      end
    end
  end
end
