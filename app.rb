require 'sinatra'
require 'grape'
require 'grape-entity'
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

DataMapper.finalize.auto_upgrade!

class Web < Sinatra::Base
  set :public_folder, Proc.new { File.join(root, "public/swagger_ui/dist") }

  get '/' do
    swagger_doc_url = request.base_url + '/api/swagger_doc'
    redirect "/index.html?url=#{swagger_doc_url}"
  end

  get '/r/:code' do
    code = params['code']
    url = URL.find_by_code(code)
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

  class UrlEntity < Grape::Entity
    expose :long_url, as: :longUrl
    expose :shortUrl do |url, options|
      request = options[:request]
      request.base_url + '/r/' + URL.id_to_code(url.id)
    end
  end

  class ErrorEntity < Grape::Entity
    expose :error
  end

  class Url < Grape::API
    resource :url do
      desc "Create a shortened URL" do
        http_codes [
          { code: 201, message: 'Create a shortened URL', model: UrlEntity },
          { code: 422, message: 'Unable to process entity', model: ErrorEntity }
        ]
      end
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
        present url, with: UrlEntity, request: request
      end

      desc 'Get information about a shortened URL' do
        http_codes [
          { code: 200, message: 'Info about shortened URL', model: UrlEntity },
          { code: 422, message: 'Unable to process entity', model: ErrorEntity }
        ]
      end
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
        code = url_match[1]
        url = URL.find_by_code(code)

        if (url.nil?)
          raise ArgumentError, "#{short_url} does not exist in our database"
        end

        present url, with: UrlEntity, request: request
      end
    end

    rescue_from :all do |e|
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
