require 'spec_helper'

describe Shoegaze::Proxy do
  describe "#new" do
    let!(:mock_class_double){ double }
    let!(:mock_instance_double){ double }
    let!(:proxy){ Shoegaze::Proxy.new(mock_class_double, mock_instance_double) }

    it "returns a new anonymous class inherited from Shoegaze::Proxy::Template" do
      expect(proxy.ancestors[1]).to eq(Shoegaze::Proxy::Template)
    end

    it "sets the proxy class and instance doubles" do
      expect(proxy.class_double).to eq(mock_class_double)
      expect(proxy.instance_double).to eq(mock_instance_double)
    end
  end
end
