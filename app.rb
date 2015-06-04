### MAIN
require "sinatra"
require "json"
require "config_env"
require 'rack-flash'
require_relative './model/user.rb'
require_relative './helpers/creditcard_helpers.rb'

require_relative './model/credit_card.rb'
require 'rack/ssl-enforcer'

# Credit Card Web Service
class CreditCardAPI < Sinatra::Base
  include CreditCardHelper

  enable :logging

  configure do
    use Rack::Session::Cookie, secret: ENV['MSG_KEY']
    use Rack::Flash, sweep: true
  end

  configure :production do
    use Rack::SslEnforcer
    set :session_secret, ENV['MSG_KEY']
  end

  before do
    @current_user = session[:auth_token] ? find_user_by_token(session[:auth_token]) : nil
  end

  get '/login' do
    haml :login
  end

  post '/login' do
    username = params[:username]
    password = params[:password]
    user = User.authenticate!(username, password)
    if user # user found
      login_user(user)
    else
      flash[:error] = 'User does not exists. <a href="/register"> Register here</a>'
      redirect '/login'
    end

  end

  get '/logout' do
    session[:auth_token] = nil
    redirect '/'
    flash[:notice] = 'You have been succesfully logged out.'
  end

  get '/register' do
    haml :register
    if token = params[:token]
      begin
        create_user_with_encrypted_token(token)
        flash[:notice] = 'Welcome! Your account has been successfully created.'
      rescue
        flash[:error] = 'Your account could not be created. Your link is either expired or is invalid'
      end
      redirect '/'
    else
      haml :register
    end
  end

  post '/register' do
    registration = Registration.new(params)

    if (registration.complete?) && (params[:password] == params[:password_confirm])
      begin
        email_registration_verification(registration)
        flash[:notice] = 'A verification link sent. Please check the email address provided.'
        redirect '/'
      rescue => e
        logger.error "FAIL EMAIL: #{e}"
        flash[:error] = 'Could not send registration verification: check email address'
        redirect '/register'
      end
    else
      flash[:error] = 'Please fill in all fields and make sure passwords match'
      redirect '/register'
    end
  end

  

  configure :development, :test do
    require 'hirb'
    Hirb.enable
    ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
  end

  get '/' do
    haml :index # "The CreditCardAPI service is running"
  end

  get '/api/v1/credit_card/?' do
    logger.info('FEATURES')
    'TO date, services offered include<br>' \
    ' GET api/v1/credit_card/validate?card_number=[card number]<br>' \
    ' GET <a href="/api/v1/credit_card/everything"> Numbers </a> '
  end

  get '/api/v1/credit_card/validate' do
    card = CreditCard.new(number: params[:card_number])
    {"Card" => params[:card_number], "validated" => card.validate_checksum}.to_json
  end

  post '/api/v1/credit_card' do
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
