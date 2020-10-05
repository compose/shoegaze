require 'spec_helper'

describe Shoegaze::Datastore do
  include SpecHelpers

  before :all do
    @klass = random_named_class
    @klass.extend(Shoegaze::Datastore)

    @klass.datastore("Pony") do
      id { 123 }
      hoofs { 5 }
      name { "Jeff" }
    end
  end

  describe "#datastore" do
    let!(:created_class){ @klass.const_get("Pony") }

    describe "created model class" do
      it "creates a TopModel class with the specified name inside the class' namespace" do
        expect(created_class.ancestors[1]).to eq Shoegaze::Model
      end
    end

    describe "factory" do
      let!(:model_instance) do
        FactoryBot.create(created_class.name.underscore, id: 5, name: "Carlos")
      end

      it "creates persisted instances" do
        expect(model_instance.hoofs).to eq(5)
        expect(model_instance.name).to eq("Carlos")
        expect(created_class.find(5)).to eq(model_instance)
      end
    end
  end
end
