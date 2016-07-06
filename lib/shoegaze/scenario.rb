require_relative 'scenario/mock'
require_relative 'scenario/orchestrator'

module Shoegaze
  class Scenario
    def initialize(method_name, &block)
      @_method_name = method_name

      self.instance_eval(&block)
    end

    # Specifies the (optional) representer to use when returning the evaluated data
    # source. If no representer is specified, the data source itself is returned
    # untouched. You can specify either a stand-alone Representable::Decorator, or provide
    # an inline one implementation via a block. This is a getter and a setter. Call it with no
    # arg to _get_ the current representer.
    #
    # @param representer_class [Representable::Decorator] (optional) A decorator class that will be used to wrap the result of the data source.
    # @param representer_block [Block] (optional) An inline Representable::Decorator implementation expressed as a block.
    # @return [Shoegaze::Orchestrator] The created or referenced representer.
    def representer(representer_class = nil, &block)
      if representer_class
        @_representer = representer_class
      end

      if block_given?
        @_representer = Class.new(Representable::Decorator).class_eval do
          self.class_eval(&block)
          self
        end
      end

      @_representer
    end

    # Specifies the method to call on the scenario's representer. Common examples as
    # :as_json or :to_json. You can omit this and, if a representer is specified, the
    # representer itself will be returned. This is a getter and a setter. Call it with no
    # arg to _get_ the current representation_method.
    #
    # @param representation_method [Symbol] The method to call on the Representable::Decorator, the result of which is ultimately returned out of the implementation of this scenario.
    # @return [Symbol] The representation method
    def represent_method(representation_method = nil)
      if representation_method
        @_representation_method = representation_method
      end

      @_representation_method
    end

    # Specifies the datasource (actual implementation code) for the implementation scenario. This is ruby code in a block. The result of this block is fed into the scenario representer, if one is specified, or returned untouched if the scenario is not represented.
    #
    # @param block [Block] The implementation for the scenario's data source expressed as a block.
    # @return [Block] The block
    def datasource(&block)
      @_datasource = block
    end

    # This just returns the datasource block.
    #
    # @return [Block] The current data source block
    def to_proc
      @_datasource
    end
  end
end
