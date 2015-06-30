### MAIN
require 'sinatra'
require 'json'
require 'config_env'
require_relative './helpers/app_helper'
require_relative './model/credit_card.rb'
# require 'rack/ssl-enforcer'
require 'dalli'

# Credit Card Web Service
class CreditCardAPI < Sinatra::Base
  include AppHelper
  enable :logging

  # configure :production do
  #   use Rack::SslEnforcer
  #   set :session_secret, ENV['MSG_KEY']
  # end

  configure :development, :test do
    require 'hirb'
    Hirb.enable
    ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
  end

  configure do
    # use Rack::Session::Cookie, secret: settings.session_secret
    set :ops_cache,
        Dalli::Client.new((ENV['MEMCACHIER_SERVERS'] || '').split(','),
                          username: ENV['MEMCACHIER_USERNAME'],
                          password: ENV['MEMCACHIER_PASSWORD'],
                          socket_timeout: 1.5,
                          socket_failure_delay: 0.2
                         )
  end

  get '/' do
    'The CreditCardAPI service is running'
  end

  get '/api/v1/credit_card/?' do
    logger.info('FEATURES')
    if params[:user_id]
      halt 401 unless authenticate_client_from_header(env['HTTP_AUTHORIZATION'])
      cards = CreditCard.where(user_id: @user_id)
      settings.ops_cache.set(@user_id, cards.map(&:to_s).to_json)
      cards.map(&:to_s).to_json
    else
      'TO date, services offered include<br>' \
      ' GET api/v1/credit_card/validate?card_number=[card number]<br>' \
      ' GET <a href="/api/v1/credit_card/everything"> Numbers </a> '
    end
  end

  get '/api/v1/credit_card/validate' do
    logger.info('VALIDATE')
    begin
      halt 401 unless authenticate_client_from_header(env['HTTP_AUTHORIZATION'])
      card = CreditCard.new(number: params[:number])
      { 'Card' => card.number, 'validated' => card.validate_checksum }.to_json
    rescue => e
      logger.error(e)
      redirect '/api/v1/credit_card'
    end
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
      card.user_id = @user_id
      halt 400 unless card.validate_checksum
      if card.save
        cards = CreditCard.where(user_id: @user_id)
        settings.ops_cache.set(@user_id, cards.map(&:to_s).to_json)
        status 201
      end
    rescue => e
      logger.error(e)
      halt 410
    end
  end

  # get '/api/v1/credit_card/everything' do
  #   CreditCard.all.map(&:to_s)
  # end
end
