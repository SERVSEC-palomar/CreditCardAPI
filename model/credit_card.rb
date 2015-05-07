 # Doc ruby URL http://ruby-doc.org/stdlib-2.0/libdoc/json/rdoc/JSON.html

require 'sinatra/activerecord'
require_relative '../environments'
require_relative '../lib/luhn_validator.rb'
require 'json'
require 'openssl'
require 'rbnacl/libsodium'
require 'base64'

class CreditCard < ActiveRecord::Base
  include LuhnValidator # TODO: mixin the LuhnValidator using an 'include' statement
  def key
      ENV['DB_KEY'].dup.force_encoding Encoding::BINARY
    end

    def number=(params_str)
      secret_box = RbNaCl::SecretBox.new(key)
      nonce = RbNaCl::Random.random_bytes(secret_box.nonce_bytes)
      ciphertext = secret_box.encrypt(nonce, params_str)
      self.nonce = Base64.urlsafe_encode64(nonce)
      self.encrypted_number = Base64.urlsafe_encode64(ciphertext)
    end

    def number
      secret_box = RbNaCl::SecretBox.new(key)
      nonce = Base64.urlsafe_decode64(self.nonce)
      stored_secret = Base64.urlsafe_decode64(self.encrypted_number)
      secret_box.decrypt(nonce, stored_secret)
    end
  # instance variables with automatic getter/setter methods
  # attr_accessor :number, :expiration_date, :owner, :credit_network

  # def initialize(number, expiration_date, owner, credit_network)
  # # DONE - TODO: initialize the instance variables listed above (do not forget the '@')
  #   @number = number
  #   @expiration_date = expiration_date
  #   @owner = owner
  #   @credit_network = credit_network
  # end

  # returns json string
  def to_json
    {
      # TODO: setup the hash with all instance vairables to serialize into json
      :number => number,
      :expiration_date => expiration_date,
      :owner => owner,
      :credit_network => credit_network
     }.to_json
  end

  # returns all card information as single string
  def to_s
    self.to_json
  end

# return a new CreditCard object given a serialized (JSON) representation
def self.from_s(card_s)
  # TODO: deserializing a CreditCard object
  new(*(JSON.parse(card_s).values))
end

# return a hash of the serialized credit card object
def hash
  # TODO: Produce a hash (using default hash method) of the credit card's
  #       serialized contents.
  #       Credit cards with identical information should produce the same hash.
  self.to_s.hash
end

# return a cryptographically secure hash
def hash_secure
  # TODO: Use sha256 from openssl to create a cryptographically secure hash.
  #       Credit cards with identical information should produce the same hash.

  sha256 = OpenSSL::Digest::SHA256.new
  sha256.digest(self.to_s).unpack('h*')
end

end
