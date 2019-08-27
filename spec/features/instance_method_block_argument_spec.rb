require 'spec_helper'

class BlockInstanceMethod
  def instance_method_that_takes_a_block(&block)
    block.call + " the grass"
  end
end

class FakeBlockInstanceMethod < Shoegaze::Mock
  mock "BlockInstanceMethod"

  implement_instance_method :instance_method_that_takes_a_block do
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

describe FakeBlockInstanceMethod do
  let!(:mock){ FakeBlockInstanceMethod.proxy }

  describe "default scenario" do
    let!(:block) do
      proc do
        "Cut"
      end
    end

    it "runs the default scenario datasource, passing in the block" do
      result = mock.new.instance_method_that_takes_a_block(&block)
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
      FakeBlockInstanceMethod.instance_call(:instance_method_that_takes_a_block).with(no_args).yields(:cheesy)
    end

    it "runs the :cheesy scenario datasource, passing in the block" do
      result = mock.new.instance_method_that_takes_a_block(&block)

      expect(result).to eq("Cut the cheese")
    end
  end
end
