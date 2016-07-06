require 'spec_helper'

describe Shoegaze::Proxy::Template do
  let!(:instance_double) do
    mock_double = double

    Shoegaze::Mock.send(:extend_double_with_extra_methods, mock_double)
    mock_double
  end

  let!(:class_double) do
    mock_double = double

    Shoegaze::Mock.send(:extend_double_with_extra_methods, mock_double)
    mock_double
  end

  before :each do
    Shoegaze::Proxy::Template.class_double = class_double
    Shoegaze::Proxy::Template.instance_double = instance_double
  end

  describe "instance method calls" do
    it "get delegated to the instance double" do
      expect(instance_double).to receive(:rights).and_return(:liberties)
      expect(Shoegaze::Proxy::Template.new.rights).to eq(:liberties)
    end
  end

  describe "class method calls" do
    it "get delegated to the class double" do
      expect(class_double).to receive(:government).and_return(:nothing_of_value)
      expect(Shoegaze::Proxy::Template.government).to eq(:nothing_of_value)
    end
  end
end
