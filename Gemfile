source 'https://rubygems.org'

# ruby '2.2.3'

gem 'sinatra'
gem 'grape', '~>0.14.0'
gem 'data_mapper'
gem 'grape-swagger', '0.20.1'
gem 'rake'
gem 'puma'

group :development, :test do
  gem 'rspec'
  gem 'dm-sqlite-adapter'
  gem 'rack-test'
end

group :production do
  gem 'pg'
  gem 'dm-postgres-adapter'
end
