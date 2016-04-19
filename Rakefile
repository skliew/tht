begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

task :default => [:spec]

namespace :db do
  task :recreate do
    require_relative 'app'
    DataMapper.auto_migrate!
  end
end

