module Shoegaze
  class Scenario
    class Mock
      include Proxy::Interface

      class << self
        # This is a mocking interface for all mocking contexts except for the top-level
        # mocking context. in other words, when you're chaining implementation calls, this
        # interface will be used beyond the top-level context. It behaves almost exactly
        # like Shoegaze::Mock.
        #
        # example:
        #
        #   class Fake < Shoegaze::Mock
        #     mock Real
        #
        #     implement :accounts do # top-level Shoegaze::Mock interface
        #       scenario :success do
        #         datasource do
        #           implement :create do # Shoegaze::ScenarioMock interface from now on
        #             default do
        #               datasource do
        #                 implement :even_more_things # yup, still Shoegaze::ScenarioMock...
        #                   default do
        #                     datasource do |params|
        #                       OkayFinally.new(params)
        #                     end
        #                   end
        #                 end
        #               end
        #             end
        #           end
        #         end
        #       end
        #     end
        #   end
        def mock(_nothing = nil)
          @_mock_class = double
          @mock_class_double = double
          @mock_instance_double = double

          extend_double_with_extra_methods(@mock_instance_double)
          extend_double_with_extra_methods(@mock_class_double)

          @implementations = {class: {}, instance: {}}

          proxy
        end
      end
    end
  end
end
