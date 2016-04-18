require 'data_mapper'

class URL
  include DataMapper::Resource

  property :id, Serial, :index => true
  property :long_url, String, :index => true

end
