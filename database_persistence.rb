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
      SELECT exercises.name, ew.sets, ew.reps_per_set, ew.rest_time_mins FROM exercises_workouts ew 
      JOIN exercises ON ew.exercise_id = exercises.id
      WHERE workout_id = $1
    SQL
    query(sql, workout_id).values
  end
  
  def find_workout(id)
    sql = "SELECT name, worked_out_on FROM workouts WHERE id = $1"
    result = query(sql, id)
    result.values
  end
end