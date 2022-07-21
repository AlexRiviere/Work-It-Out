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
  @storage.add_workout(workout_name, workout_date)
  session[:success] = 'A new workout has been created.'

  redirect "/workouts/#{@storage.find_workout_id(workout_name)}"
end

# view the workout with all its exercises
get '/workouts/:workout_id' do 
  @workout = @storage.find_workout(params[:workout_id]).flatten
  @exercises = @storage.list_exercises_from_workout(params[:workout_id])
  
  erb :view_workout
end

# view the page where you can add a new exercise to an existing workout

get '/workouts/:workout_id/exercises/new' do
  @workout = @storage.find_workout(params[:workout_id]).flatten
  erb :add_exercise
end

def sets_reps_validation(input)
  input.to_i < 0 || input.to_i.to_s != input
end

# weight in pounds needs to be less than 1000 and have no more than 2 decimals
def weight_validation(weight)
  weight.to_i < 1000 && weight.to_i >= 0
end

# 	- rest should have no more than 1 decimal place


# Create a new exercise in the database

post '/workouts/:workout_id/exercises/new' do

  binding.pry  
  @storage.add_exercise(params[:workout_id], params[:exercise_name], params[:sets], params[:reps_per_set], params[:weight_lbs], params[:rest_time_mins], )

  
  redirect "/workouts/#{params[:workout_id]}"
end