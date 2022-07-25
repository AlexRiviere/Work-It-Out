require "pg"
require "pry"

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: "workouts")
    @logger = logger
  end
  
  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end
  
  def list_all_workouts
    sql = "SELECT * FROM workouts ORDER BY worked_out_on DESC"
    result = query(sql)
    result.values
  end
  
  def add_workout(name, date)
    sql = "INSERT INTO workouts (name, worked_out_on) VALUES ($1, $2)"
    query(sql, name, date)
  end
  
  def list_exercises_from_workout(workout_id)
    sql = <<~SQL 
      SELECT exercises.name, ew.sets, ew.reps_per_set, ew.weight_lbs, ew.rest_time_mins, ew.id FROM exercises_workouts ew 
      JOIN exercises ON ew.exercise_id = exercises.id
      WHERE workout_id = $1
    SQL
    query(sql, workout_id)
  end
  
  def find_workout(id)
    sql = "SELECT name, worked_out_on FROM workouts WHERE id = $1"
    result = query(sql, id)
    result.values
  end
  
  def add_exercise(workout_id, name, input_array)
    sets, reps, weight, rest = input_array
    unless exercise_exists?(name)
      add_new_exercise(name)
    end

    sql = <<~SQL
      INSERT INTO exercises_workouts (workout_id, exercise_id, sets, reps_per_set, weight_lbs, rest_time_mins)
      VALUES ($1, $2, $3, $4, $5, $6)
    SQL
    query(sql, workout_id, find_exercise_id(name), sets, reps, weight, rest)
  end
  
  def find_workout_id(name)
    sql = "SELECT id FROM workouts WHERE name = $1"
    result = query(sql, name)
    result.values.flatten[0]
  end
  
  def find_instance_of_exercise(instance_id)
    sql = <<~SQL 
      SELECT exercises.name, ew.sets, ew.reps_per_set, ew.weight_lbs, ew.rest_time_mins FROM exercises_workouts ew
      JOIN exercises ON exercises.id = ew.exercise_id
      WHERE ew.id = $1
    SQL
    result = query(sql, instance_id)
    result[0]
  end
  
  def edit_exercise(instance_id, exercise_name, input_array)
    sets, reps, weight, rest = input_array
    unless exercise_exists?(exercise_name)
      add_new_exercise(exercise_name)
    end

    sql = <<~SQL
      UPDATE exercises_workouts SET exercise_id = $1, sets = $2, 
      reps_per_set = $3, weight_lbs = $4, rest_time_mins = $5
      WHERE id = $6
    SQL
    query(sql, find_exercise_id(exercise_name), sets, reps, weight, rest, instance_id)
  end
  
  def delete_exercise(instance_id)
    sql = "DELETE FROM exercises_workouts WHERE id = $1"
    query(sql, instance_id)
  end
  
  def delete_workout(workout_id)
    sql = "DELETE FROM workouts WHERE id = $1"
    query(sql, workout_id)
  end
  
  private 
  
  def exercise_exists?(exercise_name)
    sql = "SELECT name FROM exercises WHERE name = $1"
    result = query(sql, exercise_name)
    result.ntuples == 1
  end
  
  def add_new_exercise(exercise_name)
    sql = "INSERT INTO exercises (name) VALUES ($1)"
    query(sql, exercise_name)
  end
  
  def find_exercise_id(exercise_name)
    sql = "SELECT id FROM exercises WHERE name = $1"
    result = query(sql, exercise_name)
    result.values.flatten[0].to_i
  end
end