require 'sinatra'
require 'tilt/erubis'
require "sinatra/content_for"
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
  def all_exercise_info_nil?(exercise_row_hash)
    exercise_info = get_all_exercise_info(exercise_row_hash)
    exercise_info.keys.all? { |value| value.nil? }
  end
  
  def get_all_exercise_info(exercise_row_hash)
    exercise_row_hash.select do |col_name, _|
      col_name != "name" && col_name != "id"
    end
  end
  
  def get_all_non_nil_exercise_info(exercise_row_hash)
    get_all_exercise_info(exercise_row_hash).select { |_, value| !value.nil? }
  end
  
  def get_label_info(col_name)
    case col_name
    when "sets" then ["Sets"]
    when "reps_per_set" then ["Reps"] 
    when "weight_lbs" then ["Weight", "lbs"]
    when "rest_time_mins" then ["Rest", "minutes"]
    end
  end  
  
  def get_workout_info(workout_id)
    @storage.find_workout(workout_id).flatten
  end
end

before do   
  @storage = DatabasePersistence.new(logger)
end

after do
  @storage.disconnect
end

get '/' do 
  redirect '/workouts'
end

# View the Homepage which is a list of workouts, with their names and dates in chronological order
get '/workouts' do
  @workouts_arr = @storage.list_all_workouts
  erb :index
end

# View the form to add a new workout 
get '/workouts/new' do
  erb :add_workout
end

# Create a new workout 
post '/workouts/new' do
  workout_name = params[:workout_name]
  workout_date = params[:workout_date]
  @storage.add_workout(workout_name, workout_date)
  session[:success] = 'A new workout has been created.'

  redirect "/workouts/#{@storage.find_workout_id(workout_name)}"
end

# view the workout with all its exercises
get '/workouts/:workout_id' do 
  @workout = get_workout_info(params[:workout_id])
  @exercises = @storage.list_exercises_from_workout(params[:workout_id])
  
  erb :view_workout
end

# view the page where you can add a new exercise to an existing workout

get '/workouts/:workout_id/exercises/new' do
  @workout = get_workout_info(params[:workout_id])
  erb :add_exercise
end

def sets_reps_validation(input)
  (input.to_i > 0 && input.to_i.to_s == input) || input.empty?
end

def weight_validation(weight)
  (weight.to_i < 1000 && weight.to_i >= 0) || weight.empty?
end

def rest_validation(rest)
  rest.to_i < 10 || rest.empty?
end

def valid_input?(input_array)
  sets_reps_validation(input_array[0]) &&
  sets_reps_validation(input_array[1]) &&
  weight_validation(input_array[2]) &&
  rest_validation(input_array[3])
end

def convert_empty_strings_to_nil(array)
  array.map do |input|
    input.empty? ? nil : input
  end
end

# Create a new exercise in the database

post '/workouts/:workout_id/exercises/new' do
  
  @workout = get_workout_info(params[:workout_id])
  input_array = [params[:sets], params[:reps_per_set], params[:weight_lbs], params[:rest_time_mins]]
    
  if valid_input?(input_array)
    @storage.add_exercise(params[:workout_id], params[:exercise_name], convert_empty_strings_to_nil(input_array))
    session[:success] = "Exercise added."
    redirect "/workouts/#{params[:workout_id]}"
  else 
    session[:error] = <<-ERROR
      Sets/Reps must be a positive integers.
      Weight must be positive and less than 1000lbs.
      Rest must be less than 10 minutes. 
    ERROR
    erb :add_exercise
  end

end

# view the page where you can edit an exercise that already exists

get '/workouts/:workout_id/edit_exercise/:instance_id' do
  @workout = get_workout_info(params[:workout_id])
  @instance = @storage.find_instance_of_exercise(params[:instance_id])
  erb :edit_exercise
end


# Edit the exercise

post '/workouts/:workout_id/edit_exercise/:instance_id' do
  @workout = get_workout_info(params[:workout_id])
  @instance = @storage.find_instance_of_exercise(params[:instance_id])
  input_array = [params[:sets], params[:reps_per_set], params[:weight_lbs], params[:rest_time_mins]]
  if valid_input?(input_array)
    @storage.edit_exercise(params[:instance_id], params[:exercise_name], convert_empty_strings_to_nil(input_array))
    session[:success] = "Exercise added."
    redirect "/workouts/#{params[:workout_id]}"
  else
    session[:error] = <<-ERROR
      Sets/Reps must be a positive integers.
      Weight must be positive and less than 1000lbs.
      Rest must be less than 10 minutes. 
    ERROR
    erb :edit_exercise
  end
end

# Delete an Exercise

post '/workouts/:workout_id/delete_exercise/:instance_id' do
  @storage.delete_exercise(params[:instance_id])
  session[:success] = 'The exercise has been deleted.'
  redirect "/workouts/#{params[:workout_id]}"
end

# Delete a Workout

post '/workouts/delete_workout/:workout_id' do
  @storage.delete_workout(params[:workout_id])
  session[:success] = 'The workout has been deleted.'
  redirect '/'
end
