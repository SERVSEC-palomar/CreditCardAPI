## API 
require "sinatra"
require "json"
require "config_env"

require_relative './model/credit_card.rb'
require_relative './helpers/creditcard_helper'

# Credit Card Web Service
class CreditCardAPI < Sinatra::Base
  include CreditCardHelper
  enable :logging

  configure :development, :test do
    require 'hirb'
    Hirb.enable
    ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
  end

  get '/' do
    "The CreditCardAPI service is running"
  end

  get '/api/v1/credit_card/?' do
    if params[:user_id]
      halt 401 unless authenticate_client_from_header(env['HTTP_AUTHORIZATION'])
      user_id = @user_id
      user_card = CreditCard.where(user_id: user_id)
      if user_card.empty?
        halt 404
      else
        return user_card.map(&:to_s)
      end
    else
      logger.info('FEATURES')
      'TO date, services offered include<br>' \
      ' GET api/v1/credit_card/validate?card_number=[card number]<br>' \
      ' GET <a href="/api/v1/credit_card/everything"> Numbers </a> '
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
