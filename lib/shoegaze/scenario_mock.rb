module Shoegaze
  class ScenarioMock
    extend ProxyInterface

    class << self
      def implementations
        return @implementations if @implementations

        @_mock_class = self
        @implementations = {class: {}, instance: {}}
      end
    end
  end
end
