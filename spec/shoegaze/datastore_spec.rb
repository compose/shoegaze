require 'spec_helper'

describe Shoegaze::Datastore do
  before :all do
    # generate a dynamic named class to avoid test suite conflicts
    @class_name = "TestClass#{SecureRandom.hex(8)}"
    eval("class #{@class_name}; extend Shoegaze::Datastore; end")
    @klass = @class_name.constantize

    @klass.datastore("Pony") do
      id 123
      hoofs 5
      name "Jeff"
    end
  end

  describe "#datastore" do
    let!(:created_class){ @klass.const_get("Pony") }

    describe "created model class" do
      it "creates a TopModel class with the specified name inside the class' namespace" do
        expect(created_class.ancestors[1]).to eq TopModel::Base
      end
    end

    describe "factory" do
      let!(:model_instance) do
        FactoryGirl.create(created_class.name.underscore, id: 5, name: "Carlos")
      end

      it "creates persisted instances" do
        expect(model_instance.hoofs).to eq(5)
        expect(model_instance.name).to eq("Carlos")
        expect(created_class.find(5)).to eq(model_instance)
      end
    end
  end
end
