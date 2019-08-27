require 'spec_helper'

class BlockClassMethod
  class << self
    def class_method_that_takes_a_block(&block)
      block.call + " the grass"
    end
  end
end

class FakeBlockClassMethod < Shoegaze::Mock
  mock "BlockClassMethod"

  implement_class_method :class_method_that_takes_a_block do
    default do
      datasource do |*args, &block|
        block.call + " my hair"
      end
    end

    scenario :cheesy do
      datasource do |*args, &block|
        block.call + " the cheese"
      end
    end
  end
end

describe FakeBlockClassMethod do
  let!(:mock){ FakeBlockClassMethod.proxy }

  describe "good scenario" do
    let!(:block) do
      proc do
        "Cut"
      end
    end

    it "runs the default scenario datasource, passing in the block" do
      result = mock.class_method_that_takes_a_block(&block)
      expect(result).to eq("Cut my hair")
    end
  end

  describe "cheesy scenario" do
    let!(:block) do
      proc do
        "Cut"
      end
    end

    before do
      FakeBlockClassMethod.class_call(:class_method_that_takes_a_block).with(no_args).yields(:cheesy)
    end

    it "runs the :cheesy scenario datasource, passing in the block" do
      result = mock.class_method_that_takes_a_block(&block)
      expect(result).to eq("Cut the cheese")
    end
  end
end
