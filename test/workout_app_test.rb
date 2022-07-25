ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../workout"

class WorkoutTest < Minitest::Test
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
  
  def setup
    @storage = DatabasePersistence.new
  end
  
  def teardown
    @storage.delete_data_from_all_tables
  end
  
  def test_index
    get "/"
    assert_equal 302, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
  end
  
  def test_home_page
    get "/workouts"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Workout Logging"
  end
  
  def test_add_workout
    post '/workouts/new', {workout_name: "chest", workout_date: "2022-07-25"}
    assert_equal 302, last_response.status
    
    get '/workouts'
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "chest"
  end

end