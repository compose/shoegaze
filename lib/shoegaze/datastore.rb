module Shoegaze
  module Datastore
    def datastore(name, &block)
      klass = create_datastore_class(name)

      FactoryGirl.define do
        factory klass do
          self.instance_eval(&block)
        end
      end
    end

    private

    def create_datastore_class(name)
      self.const_set(name, Class.new(TopModel::Base))
    end
  end
end
