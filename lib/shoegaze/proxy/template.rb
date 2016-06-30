# provides the basic 'template' for our anonymous proxy classes whose *only purpose* is to
# delegate implementation method calls to the class and instance doubles
module Shoegaze
  module Proxy
    class Template
      class << self
        attr_accessor :class_double
        attr_accessor :instance_double

        def method_missing(method, *args)
          return class_double.send(method, *args) if class_double.respond_to?(method)
          super
        end
      end

      def method_missing(method, *args)
        return self.class.instance_double.send(method, *args) if self.class.instance_double.respond_to?(method)
        super
      end
    end
  end
end
