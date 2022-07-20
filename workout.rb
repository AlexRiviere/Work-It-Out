require 'sinatra'
require 'tilt/erubis'
require "sinatra/content_for"
require 'pry'
require 'date'
require_relative "database_persistence"

configure do 
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end

helpers do 

end

before do   
  @storage = DatabasePersistence.new(logger)
end

get '/' do 
  redirect '/workouts'
end

# View the Homepage which is a list of workouts, with their names and dates in chronological order
get '/workouts' do
  @workouts_arr = @storage.list_all_workouts
  erb :index
end

# view the form to add a new workout 
get '/workouts/new' do
  erb :add_workout
end

# create a new workout 
post '/workouts/new' do
  workout_name = params[:workout_name]
  workout_date = params[:workout_date]
  binding.pry
  @storage.add_workout(workout_name, workout_date)
  # for right now, to see the frutis we will redirect to home but in the future we will redirect to the workout page
  redirect "/"
end

# view the workout with all its exercises
get '/workouts/:workout_id' do 
  @workout = @storage.find_workout(params[:workout_id]).flatten
  @exercises = @storage.list_exercises_from_workout(params[:workout_id])
  
  erb :view_workout
end