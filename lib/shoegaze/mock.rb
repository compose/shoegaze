# provides the top-level mocking interface from which our mocks will inherit
module Shoegaze
  class Mock
    include Proxy::Interface

    class << self
      def mock(class_name)
        @mock_class_double = class_double(class_name)
        @mock_instance_double = instance_double(class_name)

        extend_double_with_extra_methods(@mock_instance_double)
        extend_double_with_extra_methods(@mock_class_double)

        @implementations = {class: {}, instance: {}}

        proxy
      end
    end
  end
end
