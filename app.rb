require "sinatra"
require "json"
require "config_env"
require_relative './model/user.rb'
require_relative './helpers/creditcard_helpers.rb'

require_relative './model/credit_card.rb'

# Credit Card Web Service
class CreditCardAPI < Sinatra::Base
  include CreditCardHelper
  use Rack::Session::Cookie
  enable :logging

  before do
    @current_user = session[:user_id] ? User.find_by_id(session[:user_id]) : nil
  end

  get '/login' do
    haml :login
  end

  post '/login' do
    username = params[:username]
    password = params[:password]
    user = User.authenticate!(username, password)
    user ? login_user(user) : redirect('/login')
  end

  get '/logout' do
    session[:user_id] = nil
    redirect '/'
  end

  get '/register' do
    haml :register
  end

  post '/register' do
    logger.info('REGISTER')
    username = params[:username]
    fullname = params[:fullname]
    email = params[:email]
    address = params[:address]
    dob = params[:dob]
    password = params[:password]
    password_confirm = params[:password_confirm]
    begin
      if password == password_confirm
        new_user = User.new(username: username, email: email)
        new_user.fullname = fullname
        new_user.password = password
        new_user.address = address
        new_user.dob = dob
        new_user.save ? login_user(new_user) : fail('Could not create new user')
      else
        fail 'Passwords do not match'
      end
    rescue => e
      logger.error(e)
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
