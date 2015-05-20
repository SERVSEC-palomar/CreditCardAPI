# Created user login
require 'rbnacl/libsodium'
require 'jwt'
require 'pony'

module CreditCardHelper
  def login_user(user)
  	payload = {user_id: user.id}
    token = JWT.encode payload, ENV['MSG_KEY'], 'HS256'
    session[:auth_token] = token
    redirect '/'
  end
end
