require 'spec_helper'

class InstanceWithInitializer
  def initialize(_arg1, _arg2)
    raise "should not see this because we're mocking it"
  end
end

class FakeInstanceWithInitializer < Shoegaze::Mock
  mock "InstanceWithInitializer"
end

describe FakeInstanceWithInitializer do
  let!(:mock){ FakeInstanceWithInitializer.proxy }

  describe "mock a class with an initializer that takes arguments" do
    it "supports instantiation" do
      # we just want to prove that mocks based on objects with initializers can be
      # instantiated
      instance = mock.new("arg1", "arg2")
      expect(instance).to be_kind_of Shoegaze::Proxy::Template
    end
  end
end
