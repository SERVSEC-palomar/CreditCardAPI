

module SubstitutionCipher
  module Caesar
    # Encrypts document using key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.encrypt(document, key)

      # TODO: encrypt string using caeser cipher
      ciphertext = ""

      document.to_s.chars.map do |asc|  #each_Codepoint is like each_car but gives ord of each char
        ciphertext << case asc
          when 'a'.ord..'z'.ord
              'a'.ord + (asc.ord - 'a'.ord + key) % 26
            when 'A'.ord..'Z'.ord
              'A'.ord + (asc.ord - 'A'.ord + key) % 26
            else
              (asc.ord + key)
          end
      end
      return ciphertext

      # TODO: encrypt string using caesar cipher
    end

    # Decrypts String document using integer key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.decrypt(document, key)
      # TODO: decrypt string using caeser cipher
      ciphertext = ""

      document.to_s.chars.map do |asc|  #each_Codepoint is like each_car but gives ord of each char
        ciphertext << case asc
        when 'a'.ord..'z'.ord
            'a'.ord + (asc.ord - 'a'.ord - key) % 26
          when 'A'.ord..'Z'.ord
            'A'.ord + (asc.ord - 'A'.ord - key) % 26
          else
            (asc.ord - key).chr
        end
      end
      return ciphertext
      # TODO: decrypt string using caesar cipher
    end
  end

  module Permutation
    # Encrypts document using key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.encrypt(document, key)
      # TODO: encrypt string using a permutation cipher
      ciphertext = ""
      indexes = []
      randkey = Random.new(key)

      document.to_s.length.times { |idx| indexes << idx +10 }

      doc = document.to_s.chars.map(&:ord)
      ciphertext = doc.zip(indexes).map {|a,b| (a + randkey.rand(b)).chr }.join

      ciphertext

    end

    # Decrypts String document using integer key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.decrypt(document, key)
      # TODO: decrypt string using a permutation cipher
      ciphertext = ""
      indexes = []
      randkey = Random.new(key)

      document.to_s.length.times { |idx| indexes << idx +10 }

      doc = document.to_s.chars.map(&:ord)
      ciphertext = doc.zip(indexes).map {|a,b| (a - randkey.rand(b)).chr }.join

      ciphertext
    end
  end
end
