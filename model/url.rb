require 'data_mapper'

# Model of the application
class URL
  include DataMapper::Resource

  CHARS =
    'abcdefghijklmnopqrstuvwxyq01234567890ABCDEFGHIJKLMNOPQRSTUVWXYQ'.freeze
  SIZE = CHARS.size

  # Build a Hash of char => idx
  CHARSHASH = Hash[CHARS.split('').map.with_index.to_a]

  property :id, Serial, index: true
  property :long_url, String, length: 255, index: true

  def self.id_to_code(id)
    id ||= 0
    code = []
    while id != 0
      idx = id % SIZE
      id /= SIZE
      code << CHARS[idx]
    end
    code.join('').reverse
  end

  def self.code_to_id(code)
    result = 0
    raise ArgumentError, 'Code cannot be empty' if code.empty?
    code.split('').each do |c|
      id = CHARSHASH[c]
      raise ArgumentError, "Invalid code #{code}" if id.nil?
      result = result * SIZE + id
    end
    result
  end

  def self.find_by_code(code)
    id = code_to_id(code)
    first(id: id)
  end
end
