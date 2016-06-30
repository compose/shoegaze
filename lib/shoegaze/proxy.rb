require_relative 'proxy/template'
require_relative 'proxy/interface'

module Shoegaze
  module Proxy
    # the goal here is to create a bare-bones anonymous class that delegates all class
    # methods to the class double and all instance methods to the instance double and that
    # implements almost nothing else to avoid conflicts with the actual implementations
    def self.new(mock_class_double, mock_instance_double)
      proxy = Class.new(Template)
      proxy.class_double    = mock_class_double
      proxy.instance_double = mock_instance_double

      proxy
    end
  end
end
