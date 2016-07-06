require 'spec_helper'

describe Shoegaze::Scenario do
  let!(:method_name){ :one_weird_trick }

  describe "#initialize" do
    it "stores instance variables" do
      instance = Shoegaze::Scenario.new(method_name){}
      expect(instance.instance_variable_get(:@_method_name)).to eq(method_name)
    end

    it "evaluates the provided block" do
      expect_any_instance_of(Shoegaze::Scenario).to receive(:bananas)

      Shoegaze::Scenario.new(method_name) do
        bananas
      end
    end
  end

  describe "#representer" do
    let!(:scenario){ Shoegaze::Scenario.new(method_name){} }

    describe "with a representer passed in" do
      let!(:fake_representer_class){ double }

      it "sets and returns the representer class" do
        expect(scenario.representer(fake_representer_class)).to eq(fake_representer_class)
        expect(scenario.representer).to eq(fake_representer_class)
      end
    end

    describe "with a block passed in" do
      it "evaluates the block as a Representer::Decorator" do
        scenario.representer do
          include Representable::JSON

          property :cows
        end

        expect(scenario.representer.ancestors[1]).to eq(Representable::JSON)
      end
    end
  end

  describe "#self.represent_method" do
    let!(:scenario){ Shoegaze::Scenario.new(method_name){} }

    describe "with a representation method passed in" do
      it "sets the representation method" do
        scenario.represent_method :as_cow

        expect(scenario.represent_method).to eq(:as_cow)
      end
    end
  end

  describe "#self.datasource" do
    let!(:scenario){ Shoegaze::Scenario.new(method_name){} }
    let!(:test_block){ proc { } }

    it "stores and returns the block" do
      expect(scenario.datasource(&test_block)).to eq(test_block)
      expect(scenario.instance_variable_get(:@_datasource)).to eq(test_block)
    end

    describe "#to_proc" do
      it "returns the stored datasource" do
        expect(scenario.datasource(&test_block)).to eq(test_block)
        expect(scenario.to_proc).to eq(test_block)
      end
    end
  end
end
