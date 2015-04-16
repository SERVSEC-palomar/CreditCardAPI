module LuhnValidator
  # Validates credit card number using Luhn Algorithm
  # arguments: none
  # assumes: a local String called 'number' exists
  # returns: true/false whether last digit is correct
  def validate_checksum
    nums_a = number.to_s.chars.map(&:to_i)

    check = nums_a.pop # pops(removes) the last digit so we can check/compare with the answer in the end
    sum = nums_a.reverse.each_slice(2).map do |x, y|
    	[(x * 2).divmod(10), y || 0]
    	end.flatten.inject(:+)
    ((10 - sum) % 10) == check # implicit return / without the inner brackets, it failed against true numbers with '0' at the end (eg. 6011368353866440)

    # TODO: use the integers in nums_a to validate its last check digit
  end
end
