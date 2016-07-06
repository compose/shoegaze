module Shoegaze
  module Datastore
    # Defines both a TopModel-inherited class and a factory in the mock namespace
    #
    # @param name [Symbol] upcased name of the datastore to create (example: :User)
    # @param block [Block] FactoryGirl factory implementation expressed in a block
    # @return [Class] the created datastore class
    #
    # example:
    #
    #   datastore :User do
    #     id 123
    #     name "Karlita"
    #   end
    #
    def datastore(name, &block)
      klass = create_datastore_class(name)

      FactoryGirl.define do
        factory klass do
          self.instance_eval(&block)
        end
      end

      klass
    end

    private

    def create_datastore_class(name)
      self.const_set(name, Class.new(TopModel::Base))
    end
  end
end
