require './app.rb'
require 'sinatra/activerecord/rake'
require 'rake/testtask'

desc 'Run all tests'
Rake::TestTask.new(name = :spec) do |t|
  t.pattern = 'spec/*_spec.rb'
end