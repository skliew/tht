require 'data_mapper'

class URL
  include DataMapper::Resource

  property :id, Serial, :index => true
  property :long_url, String, :length => 255, :index => true

  CHARS = 'abcdefghijklmnopqrstuvwxyq01234567890ABCDEFGHIJKLMNOPQRSTUVWXYQ'
  SIZE = CHARS.size

  # Build a Hash of char => idx
  CHARSHASH = Hash[CHARS.split('').map.with_index.to_a]

  def self.id_to_code(id)
    id ||= 0
    code = []
    while
      idx = id % SIZE
      id /= SIZE
      code << CHARS[idx]
      break if id == 0
    end
    code.join('').reverse
  end

  def self.code_to_id(code)
    result = 0
    raise ArgumentError, "Code cannot be empty" if code.empty?
    code.split('').each do |c|
      id = CHARSHASH[c]
      raise ArgumentError, "Invalid code #{code}" if id.nil?
      result = result * SIZE + id
    end
    result
  end

end
