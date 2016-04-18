require 'spec_helper'
require 'rack/test'
require_relative '../../app'

describe UrlShortener::API do

  include Rack::Test::Methods

  def app
    UrlShortener::API
  end

  it 'shows status' do
    get '/api/status'
    expect(last_response.status).to equal(200)
  end

  it 'creates shortened URL' do
    post '/api/url', { longUrl: "http://google.com" }
    # 201 indicates resource successfully created
    expect(last_response.status).to equal(201)
  end

  it 'should fail when given an invalid URL' do
    post '/api/url', { longUrl: "12341234" }
    # 201 indicates resource successfully created
    expect(last_response.status).to equal(400)
  end
end
