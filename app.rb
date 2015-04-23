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

	post '/api/v1/credit_card' do
		number 		= nil
		expiration_date = nil
		owner 		= nil
		credit_network = nil
		request_json = request.body.read
		begin
			unless request_json.empty?
				req = JSON.parse(request_json)
				number = req['number']
				expiration_date = req['expiration_date']
				owner = req['owner']
				credit_network = req['credit_network']
			end

			card = CreditCard.new(number: number,
		                   expiration_date: expiration_date,
		                   owner: owner,
		                   credit_network: credit_network)

			if card.validate_checksum
				 if card.save
				 	status 201
				 	return body({status: 201, message: 'Created' }.to_json)
				 else
				 	halt 410
				 	body({status: 410, message: 'Resource requested is no longer available' }.to_json)
				 end
			else
				 halt 400 
				 body({status: 400, message: 'Cannot process the request'}.to_json)
			end
		rescue
			halt 400 
			body({status: 400, message:'There was an error, please check your input and try again.'}.to_json)
		end
  end

  get '/api/v1/all' do
	unless card.empty?
		CreditCard.all.to_json
		return 200
	else
	  return 500
	end
  end
end
