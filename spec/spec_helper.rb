ENV['RAILS_ENV'] = 'test'

require './lib/shoegaze'
require 'rspec'
require 'factory_girl'

Dir[File.expand_path('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
