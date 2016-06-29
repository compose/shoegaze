module Shoegaze
  class ScenarioMock
    include Proxy::Interface

    class << self
      def mock(_nothing = nil)
        @_mock_class = double
        @mock_class_double = double
        @mock_instance_double = double
        @implementations = {class: {}, instance: {}}

        proxy
      end
    end
  end
end
