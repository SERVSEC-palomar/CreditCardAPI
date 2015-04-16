require 'openssl'
require 'json'

module AesCipher
  def self.encrypt(document, key)
    # exmaple from http://ruby-doc.org/stdlib-2.0/libdoc/openssl/rdoc/OpenSSL/Cipher.html
    cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    cipher.encrypt
    cipher.key = key.to_s
    iv = cipher.random_iv
    ciphertext = cipher.update(document.to_s) + cipher.final
    return [iv, ciphertext].map(){|s| s.unpack('H*')[0]}.to_json


    # TODO: Return JSON string of array: [iv, ciphertext]
    #       where iv is the random intialization vector used in AES
    #       and ciphertext is the output of AES encryption
    # NOTE: Use hexadecimal strings for output so that it is screen printable
    #       Use cipher block chaining mode only!
  end

  def self.decrypt(aes_crypt, key)
    iv, ciphertext =  JSON.parse(aes_crypt).map {|s| [s].pack('H*')}

    decipher = OpenSSL::Cipher::AES.new(128, :CBC)
    decipher.decrypt
    decipher.key = key
    decipher.iv = iv
    plain = decipher.update(ciphertext) + decipher.final
    return plain
  end
end