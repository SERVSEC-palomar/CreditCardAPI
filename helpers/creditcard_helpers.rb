# Created user login
module CreditCardHelper
  def login_user(user)
    session[:user_id] = user.id
    redirect '/'
  end
end
