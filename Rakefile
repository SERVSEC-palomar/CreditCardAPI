require './app.rb'
require 'sinatra/activerecord/rake'
require 'rake/testtask'
require 'config_env/rake_tasks'

desc 'Run all tests'
Rake::TestTask.new(name = :spec) do |t|
  t.pattern = 'spec/*_spec.rb'
end
