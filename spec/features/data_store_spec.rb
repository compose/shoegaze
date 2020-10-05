require 'spec_helper'

class DataStoreMethod
  class << self
    def create_sock(sock_data)
      raise "should never see this"
    end

    def find_sock(sock_id)
      raise "should never see this"
    end
  end
end

class SockRepresenter < Representable::Decorator
  include Representable::JSON

  property :id
  property :created_at
  property :material, exec_context: :decorator

  def material
    represented.material.reverse
  end
end

class FakeDataStoreMethod < Shoegaze::Mock
  extend Shoegaze::Datastore

  mock "DataStoreMethod"

  datastore :Sock do
    id{ (Random.rand * 100).ceil }
    material{ [:wool, :carpet, :seal_whiskers].sample }
    created_at{ Time.now }
  end

  implement_class_method :create_sock do
    default do
      representer SockRepresenter
      represent_method :as_json

      datasource do |sock_data|
        FactoryBot.create("fake_data_store_method/sock", sock_data)
      end
    end
  end

  implement_class_method :find_sock do
    default do
      representer SockRepresenter
      represent_method :as_json

      datasource do |id|
        Sock.find(id)
      end
    end
  end
end

describe FakeDataStoreMethod do
  let!(:mock){ FakeDataStoreMethod.proxy }

  describe "persistence" do
    it "can store and retrieve objects from the datastore" do
      created_sock_data = mock.create_sock({:material => "latex"})
      expect(created_sock_data["material"]).to eq("xetal")

      found_sock_data = mock.find_sock(created_sock_data["id"])
      expect(created_sock_data).to eq(found_sock_data)
    end
  end
end
