require 'spec_helper'

class InstanceWithInitializer
  def initialize(*arg)
    raise "should never see this"
  end
end

class FakeInstanceWithInitializer < Shoegaze::Mock
  mock "Instancewithinitializer"

  implement_instance_method :initialize do
    default do
      datasource do |*arg|
        raise "mocked initializer should never work"
      end
    end
  end
end

describe FakeInstanceWithInitializer do
  let!(:mock){ FakeInstanceWithInitializer.proxy }

  describe "mock a class with customized initializer which has arguments" do
    it "support function `new`" do
      instance = mock.new("arg1", "arg2")

      expect(instance).to be_kind_of Shoegaze::Proxy::Template
    end
  end
end
