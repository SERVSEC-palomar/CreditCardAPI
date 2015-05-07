require_relative 'spec_helper'

describe 'CreditCardAPI' do

  describe 'Getting the root of the service' do
    it 'should return ok' do
      get '/'
      last_response.body.must_include 'up and running'
      last_response.status.must_equal 200
    end
  end
  
  describe 'Getting /api/v1/credit_card/validate' do
  
    before do
      CreditCard.delete_all
    end
    
     
    it 'should be ok' do
    get '/api/v1/credit_card/validate?card_number=4539075978941247'
      card = CreditCard.new(number, nil, nil, nil)
      card.validate_checksum.must_equal true
    end
    
  end

end