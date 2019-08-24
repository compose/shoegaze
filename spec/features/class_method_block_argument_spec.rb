require 'spec_helper'

class ClassMethodBlockArg
  class << self
    def gateway(&block)
      return block.call + " through gateway"
    end

    def do_something()
      return "Do something"
    end
  end
end

class FakeClassMethodBlockArg < Shoegaze::Mock
  mock "ClassMethodBlockArg"

  implement_class_method :do_something do
    default do
      datasource do
        return "Do something"
      end
    end
  end

  # ! Don't know how to add an implementation for `gateway`
  # implement_class_method :gateway do
  # ??
  # end
  # Following doesn't work
  implement_class_method :gateway do
    default do
      datasource do |&block|
        block.call + " through gateway"
      end
    end
  end
end

describe ClassMethodBlockArg do
  it "works" do
    result = ClassMethodBlockArg.gateway do
      ClassMethodBlockArg.do_something
    end

    expect(result).to eq "Do something through gateway"
  end
end

describe FakeClassMethodBlockArg do
  let!(:mock){ FakeClassMethodBlockArg.proxy }

  it "works" do
    result = mock.gateway do
      mock.do_something
    end

    expect(result).to eq "Do something through gateway"
  end
end
