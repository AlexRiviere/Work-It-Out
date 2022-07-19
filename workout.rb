require 'sinatra'
require 'tilt/erubis'
require "sinatra/content_for"
require 'pry'
require_relative "database_persistence"

configure do 
  enable :sessions
  set :session_secret, 'secret'
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end

before do   
  @storage = DatabasePersistence.new(logger)
end

# View the Homepage which is a list of workouts, with their names and dates in chronological order
get "/" do
  
end