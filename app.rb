require "sinatra"
require "json"
require "./model/credit_card.rb"

# Credit Card Web Service
class CreditCardAPI < Sinatra::Base

  get '/' do
    "The CreditCardAPI service is running"
  end

  get '/api/v1/credit_card/validate' do
    card = CreditCard.new(params[:card_number],nil,nil,nil)
    {"Card" => params[:card_number], "validated" => card.validate_checksum}.to_json
  end
end
