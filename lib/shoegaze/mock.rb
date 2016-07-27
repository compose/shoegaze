module Shoegaze
  # Provides the top-level mocking interface from which our mocks will inherit.
  class Mock
    include Proxy::Interface

    class << self
      # Creates a Shoegaze mock proxy for the provided class name
      #
      # @param class_name [String] String name of the constant to mock
      # @return [Class.new(Shoegaze::Proxy)] The created Shoegaze proxy. Use this as the replacement for your real implementation.
      #
      # example:
      #
      #   class RealClass
      #   end
      #
      #   class FakeClass < Shoegaze::Mock
      #     mock "RealClass"
      #   end
      #
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
