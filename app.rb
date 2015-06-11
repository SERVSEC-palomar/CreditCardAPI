## API 
require "sinatra"
require "json"
require "config_env"
require 'jwt'

require_relative './model/credit_card.rb'

# Credit Card Web Service
class CreditCardAPI < Sinatra::Base
  enable :logging

  configure :development, :test do
    require 'hirb'
    Hirb.enable
    ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
  end

  def authenticate_client_from_header(authorization)
    scheme, jwt = authorization.split(' ')
    ui_key = OpenSSL::PKey::RSA.new(ENV['UI_PUBLIC_KEY'])
    payload, _header = JWT.decode jwt, ui_key
    @user_id = payload['sub']
    result = (scheme =~ /^Bearer$/i) && (payload['iss'] == 'https://credit-card-service-app.herokuapp.com/')
    return result  
  rescue
    false
  end

  get '/' do
    "The CreditCardAPI service is running"
  end

  get '/api/v1/credit_card/:user_id' do
    halt 401 unless authenticate_client_from_header(env['HTTP_AUTHORIZATION'])
    content_type :json
    begin
      user_cards = CreditCard.where("user_id = ?", params[:user_id])
      user_cards.map(&:to_s)
    rescue
      halt 500
    end
  end

  get '/api/v1/credit_card/validate' do
    halt 401 unless authenticate_client_from_header(env['HTTP_AUTHORIZATION'])
    card = CreditCard.new(number: "#{params[:card_number]}")
    {"Card" => params[:card_number], "validated" => card.validate_checksum}.to_json
  end

  post '/api/v1/credit_card' do
    content_type :json
    halt 401 unless authenticate_client_from_header(env['HTTP_AUTHORIZATION'])
    card_json = JSON.parse(request.body.read)
    begin
      number = card_json['number']
      credit_network = card_json['credit_network']
      expiration_date = card_json['expiration_date']
      owner = card_json['owner']
      card = CreditCard.new(number: number, credit_network: credit_network,
                            owner: owner, expiration_date: expiration_date)
      halt 400 unless card.validate_checksum
      status 201 if card.save
    rescue
      halt 410
    end
  end

  get '/api/v1/credit_card/everything' do
    haml :everything, locals: {result: CreditCard.all.map(&:to_s)    }
  end  

end
