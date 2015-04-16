require_relative '../lib/credit_card'
require_relative '../lib/substitution_cipher'
require_relative '../lib/double_trans_cipher'
require_relative '../lib/aes_cipher'
require 'minitest/autorun'

describe 'Test card info encryption' do
  before do
    @cc = CreditCard.new('4916603231464963', 'Mar-30-2020', 'Soumya Ray', 'Visa')
    @key = 3
    @key2 = 4
    @key3 = "Some long text for ssh password"
  end

  describe 'Using Caesar cipher' do
    it 'should encrypt card information' do
      enc = SubstitutionCipher::Caesar.encrypt(@cc, @key)
      enc.wont_equal @cc.to_s
    end

    it 'should decrypt text' do
      enc = SubstitutionCipher::Caesar.encrypt(@cc, @key)
      dec = SubstitutionCipher::Caesar.decrypt(enc, @key)
      dec.must_equal @cc.to_s
    end
  end

  describe 'Using Permutation cipher' do
    it 'should encrypt card information' do
      enc = SubstitutionCipher::Permutation.encrypt(@cc, @key)
      enc.wont_equal @cc.to_s
    end

    it 'should decrypt text' do
      enc = SubstitutionCipher::Permutation.encrypt(@cc, @key)
      dec = SubstitutionCipher::Permutation.decrypt(enc, @key)
      dec.must_equal @cc.to_s
    end
  end

  # TODO: Add tests for double transposition and AES ciphers
  #       Can you DRY out the tests using metaprogramming? (see lecture slide)
  describe 'Using Double Transposition Cipher' do
    it 'Should encrypt text' do
      enc =  DoubleTranspositionCipher.encrypt(@cc, @key)
      enc.wont_equal @cc.to_s
    end

    it 'Should decrypt text and equal original text' do
      enc =  DoubleTranspositionCipher.encrypt(@cc, @key)
      dec =  DoubleTranspositionCipher.decrypt(enc, @key)
      dec.must_equal @cc.to_s
    end

    it 'Should not decrypt text with different key' do
      enc =  DoubleTranspositionCipher.encrypt(@cc, @key)
      dec =  DoubleTranspositionCipher.decrypt(enc, @key2)
      dec.wont_equal @cc.to_s
    end
  end

    hashedMethod = { "Using Double Transposition (Dry Method) Cipher" => DoubleTranspositionCipher} #, "Using AES (Dry Method) Cipher" => AesCipher #removed because AES requires a longer password than just num 3} 
  hashedMethod.each do |desc, cipher|
    describe '#{desc}' do
      it 'should encrypt text' do
        enc = cipher::encrypt(@cc, @key)
        enc.wont_equal @cc.to_s
      end

      it 'should decrypt text and equal original' do
        enc = cipher::encrypt(@cc, @key)
        dec = cipher::decrypt(enc, @key)
        dec.must_equal @cc.to_s
      end
    end
  end

  describe 'Using AES Cipher' do
    it 'Should encrypt text' do
      enc =  AesCipher.encrypt(@cc, @key3)
      enc.wont_equal @cc.to_s
    end

    it 'Should decrypt text and equal original text' do
      enc =  AesCipher.encrypt(@cc, @key3)
      dec =  AesCipher.decrypt(enc, @key3)
      dec.must_equal @cc.to_s
    end
  end

end
