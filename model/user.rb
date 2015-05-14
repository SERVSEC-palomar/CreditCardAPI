require 'sinatra/activerecord'
require 'protected_attributes'
require_relative '../environments'
require 'rbnacl/libsodium'
require 'base64'
require 'json'

class User < ActiveRecord::Base
  validates :username, presence: true, uniqueness: true
  validates :hashed_password, presence: true
  validates :email, presence: true, uniqueness: true, format: /@/
  validates :encrypted_fullname, presence: true
  validates :encrytped_address, presence: true
  validates :encrypted_dob, presence: true

  attr_accessible :username, :email

  def key
    Base64.urlsafe_decode64(ENV['DB_KEY'])
  end

  def password=(new_password)
    salt = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
    digest = self.class.hash_password(salt, new_password)
    self.salt = Base64.urlsafe_encode64(salt)
    self.hashed_password = Base64.urlsafe_encode64(digest)
  end

  def self.authenticate!(username, login_password)
    user = User.find_by_username(username)
    user && user.password_matches?(login_password) ? user : nil
  end

  def password_matches?(try_password)
    salt = Base64.urlsafe_decode64(self.salt)
    attempted_password = self.class.hash_password(salt, try_password)
    hashed_password == Base64.urlsafe_encode64(attempted_password)
  end

  def self.hash_password(salt, pwd)
    opslimit = 2**20
    memlimit = 2**24
    digest_size = 64
    RbNaCl::PasswordHash.scrypt(pwd, salt, opslimit, memlimit, digest_size)
  end

  def enc
      secret_box = RbNaCl::SecretBox.new(key)
      #@variable is instance variable, available to all methods in class
      @nonce = RbNaCl::Random.random_bytes(secret_box.nonce_bytes)
      #ciphertext = secret_box.encrypt(nonce, params_str)
      self.nonce = Base64.urlsafe_encode64(@nonce)
      #self.encrypted_number = Base64.urlsafe_encode64(ciphertext)
      secret_box 
  end

  def dec
    secret_box = RbNaCl::SecretBox.new(key)
  end

  def dob=(params)
    self.encrypted_dob = Base64.urlsafe_encode64(enc.encrypt(Base64.urlsafe_decode64(nonce), "#{params}"))
  end

  def dob
    dec.decrypt(Base64.urlsafe_decode64(nonce), Base64.urlsafe_decode64(encrypted_dob))
  end

  def address=(params)
    self.encrytped_address = Base64.urlsafe_encode64(enc.encrypt(Base64.urlsafe_decode64(nonce), "#{params}"))
  end

  def address
    dec.decrypt(Base64.urlsafe_decode64(nonce), Base64.urlsafe_decode64(encrytped_address))
  end

  def fullname=(params)
    self.encrypted_fullname = Base64.urlsafe_encode64(enc.encrypt(Base64.urlsafe_decode64(nonce), "#{params}"))
  end

  def fullname
    dec.decrypt(Base64.urlsafe_decode64(nonce), Base64.urlsafe_decode64(encrypted_fullname))
  end

    # returns json string
  def to_json
    {
      # TODO: setup the hash with all instance vairables to serialize into json
      :username => username,
      :fullname => fullname,
      :email => email,
      :address => address,
      :dob => dob,
     }.to_json
  end

  # returns all card information as single string
  def to_s
    self.to_json
  end

end
