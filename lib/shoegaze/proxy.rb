require_relative 'proxy/template'
require_relative 'proxy/interface'

module Shoegaze
  module Proxy
    # Creates a Shoegaze mock proxy that delegates all the class method calls to the class
    # double and all the instance method calls to the instance double.
    #
    # @param mock_class_double [RSpec::Mocks::ClassVerifyingDouble] RSpec class double that will receive class method calls
    # @param mock_instance_double [RSpec::Mocks::InstanceVerifyingDouble] RSpec instance double that will receive instance method calls
    # @return [Class.new(Shoegaze::Proxy)] The created Shoegaze proxy.
    #
    # The goal here is to create a bare-bones anonymous class that delegates all class
    # methods to the class double and all instance methods to the instance double such that
    # it implements almost nothing else to avoid conflicts with the actual implementations.
    def self.new(mock_class_double, mock_instance_double)
      proxy = Class.new(Template)
      proxy.class_double    = mock_class_double
      proxy.instance_double = mock_instance_double

      proxy
    end
  end
end
