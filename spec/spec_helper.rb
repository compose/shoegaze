ENV['RAILS_ENV'] = 'test'

require './lib/shoegaze'
require 'rspec'
require 'factory_girl'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
