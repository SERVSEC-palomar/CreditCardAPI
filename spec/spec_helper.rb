ENV['RACK_ENV']='test'

require 'minitest/autorun'
require 'rack/test'
require 'yaml'
require 'json'
require_relative '../app'

include Rack::Test::Methods

def app
 CreditCardAPI

end

