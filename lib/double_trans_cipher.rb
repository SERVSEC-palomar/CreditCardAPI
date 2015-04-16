module DoubleTranspositionCipher
  def self.encrypt(document, key)
    # TODO: FILL THIS IN!
    ## Suggested steps for double transposition cipher
    doc_length=document.to_s.length
    # 1. find number of rows/cols such that matrix is almost square
    if  doc_length % Math.sqrt(doc_length) == 0
        doc_row = Math.sqrt(doc_length).to_i
        doc_column= doc_row
      else
        doc_row = Math.sqrt(doc_length).ceil
        doc_column= doc_row + 1
      end

    # 2. break plaintext into evenly sized blocks
    doc=document.to_s.chars.each_slice(doc_column).to_a
    # 3. sort rows in predictibly random way using key as seed
    doc=doc.shuffle(random: Random.new(key) )
    # 4. sort columns of each row in predictibly random way
    doc=doc.collect! {|ele| ele.shuffle(random: Random.new(key))}
    # 5. return joined cyphertext
  doc.join
  end

  def self.decrypt(ciphertext, key)
    # TODO: FILL THIS IN!
        cipher_length=ciphertext.to_s.length
 if  cipher_length % Math.sqrt(cipher_length) == 0
        cipher_row = Math.sqrt(cipher_length).to_i
        cipher_column= cipher_row
      else
        cipher_row = Math.sqrt(cipher_length).ceil
        cipher_column= cipher_row + 1
      end

      seq=(0..cipher_length-1).to_a.map{|element|element.to_s}
      seq=seq.each_slice(cipher_column).to_a
      seq=seq.shuffle(random: Random.new(key) )
      seq=seq.collect! {|ele| ele.shuffle(random: Random.new(key))}
      seq=seq.flatten.map{|index| index.to_i}

      doc=ciphertext.to_s.chars.to_a
      newt = []
      count = 0

      doc.each do
        newt << doc[seq.index(count)]
#       puts newt, seq.index(count)
        count += 1
      end

      newt.join
  end
end
