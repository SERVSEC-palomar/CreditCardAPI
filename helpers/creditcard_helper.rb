require 'jwt'

module CreditCardHelper
  def authenticate_client_from_header(authorization)
    scheme, jwt = authorization.split(' ')
    ui_key = OpenSSL::PKey::RSA.new(ENV['UI_PUBLIC_KEY'])
    payload, _header = JWT.decode jwt, ui_key
    @user_id = payload['sub']
    result = (scheme =~ /^Bearer$/i) && (payload['iss'] == 'https://palomar-creditcardapi.herokuapp.com/')
    return result  
  rescue
    false
  end
end
