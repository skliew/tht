require 'sinatra'
require 'grape'
require 'grape-swagger'
require_relative 'model/url'
require_relative 'validator'

configure :test, :development do
  DataMapper.setup :default, "sqlite::memory:"
end

configure :production do
  # Expecting Heroku to set DATABASE_URL
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

DataMapper.auto_upgrade!

class Web < Sinatra::Base
  set :public_folder, Proc.new { File.join(root, "public/swagger_ui/dist") }

  get '/' do
    swagger_doc_url = request.base_url + '/api/swagger_doc'
    redirect "/index.html?url=#{swagger_doc_url}"
  end

  get '/r/:id' do
    id = params['id']
    if id !~ /^\d+$/
      raise ArgumentError, "#{id} is not a valid ID"
    end
    url = URL.first(id: id)
    if (url.nil?)
      raise ArgumentError, "#{id} does not exist in our database"
    end
    if url.long_url != request.url
      redirect url.long_url
    else
      url.long_url
    end
  end
end

module UrlShortener
  class Url < Grape::API
    resource :url do
      desc "Create a shortened URL"
      params do
        requires :longUrl, :type => String, :desc => 'URL to shorten', valid_url: true
      end
      post do
        long_url = params[:longUrl]
        url = URL.first_or_create(long_url: long_url)
        unless url.saved?
          # errors is not an Array
          message = url.errors.to_a.join("\n")
          raise ArgumentError, message
        end
        short_url = request.base_url + '/r/' + url.id.to_s
        {longUrl: long_url, shortUrl: short_url}
      end

      desc 'Get information about a shortened URL'
      params do
        requires :shortUrl, :type => String, :desc => 'Shortened URL', valid_url: true
      end
      get do
        short_url = params[:shortUrl]
        shortened_url_base = request.base_url + '/r/'
        url_match = /#{shortened_url_base}(.*)/.match(short_url)
        if (url_match.nil?)
          raise ArgumentError, "#{short_url} is not recognizable"
        end
        id = url_match[1]
        url = URL.first(id: id)

        if (url.nil?)
          raise ArgumentError, "#{short_url} does not exist in our database"
        end

        {shortUrl: short_url, longUrl: url.long_url}
      end
    end

    rescue_from ArgumentError, Grape::Exceptions::ValidationErrors do |e|
      error!({ error: e.message }, 422, { 'Content-Type' => 'application/json' })
    end

  end

  class Status < Grape::API
    resource :status do
      desc "Get service's status"
      get do
        {status: :ok}
      end
    end
  end

  class API < Grape::API
    prefix 'api'
    format :json
    mount UrlShortener::Url
    mount UrlShortener::Status

    if ENV['RACK_ENV'] == 'production'
      add_swagger_documentation
    else
      add_swagger_documentation schemes: ['http']
    end
  end

end
