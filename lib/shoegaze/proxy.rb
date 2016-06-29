require_relative 'proxy/template'
require_relative 'proxy/interface'

module Shoegaze
  module Proxy
    def self.new(mock_class_double, mock_instance_double)
      proxy = Class.new(Template)

      proxy.class_double    = mock_class_double
      proxy.instance_double = mock_instance_double

      proxy
    end
  end
end
