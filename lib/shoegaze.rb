module Shoegaze
end

require 'active_support'
require 'rspec'
require 'activemodel-serializers-xml'
require 'top_model'
require 'representable'
require 'multi_json'
require 'representable/json'

require_relative 'shoegaze/datastore'
require_relative 'shoegaze/implementation'
require_relative 'shoegaze/proxy'
require_relative 'shoegaze/mock'
require_relative 'shoegaze/scenario'
