module Shoegaze
  class Mock
    include Proxy::Interface

    class InvalidNamespaceError < StandardError; end

    class << self
      def mock(class_name)
        @_class_name = class_name
        @mock_class_double = class_double(class_name)
        @mock_instance_double = instance_double(class_name)
        @implementations = {class: {}, instance: {}}

        proxy
      end
    end
  end
end
