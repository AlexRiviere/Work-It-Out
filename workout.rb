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

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

before do   
  @storage = DatabasePersistence.new(logger)
end

# View the Homepage which is a list of categories
get "/" do
  @categories = @storage.category_names
  erb :index
end