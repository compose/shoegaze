module Shoegaze
  class Scenario
    def initialize(method_name, &block)
      @_method_name = method_name

      self.instance_eval(&block)
    end

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

    def represent_method(representation_method = nil)
      if representation_method
        @_representation_method = representation_method
      end

      @_representation_method
    end

    def datasource(&block)
      @_datasource = block
    end

    def to_proc
      @_datasource
    end
  end
end
