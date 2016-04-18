source "https://rubygems.org"

#ruby '2.2.3'

gem "sinatra"
gem "grape"
gem 'data_mapper'
gem 'grape-swagger'
gem 'rake'

group :development, :test do
  gem 'rspec'
  gem 'dm-sqlite-adapter'
  gem 'rack-test'
end

group :production do
  gem 'pg'
  gem 'dm-postgres-adapter'
end
