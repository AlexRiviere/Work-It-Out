CREATE TABLE workouts (
  id serial PRIMARY KEY,
  name text NOT NULL,
  worked_out_on date NOT NULL
);

CREATE TABLE exercises (
  id serial PRIMARY KEY,
  name text NOT NULL
);

CREATE TABLE exercises_workouts (
  id serial PRIMARY KEY,
  workout_id integer NOT NULL REFERENCES workouts (id) ON DELETE CASCADE,
  exercise_id integer NOT NULL REFERENCES exercises (id) ON DELETE CASCADE,
  sets integer,
  reps_per_set integer,
  weight_lbs decimal(5, 2),
  rest_time_mins decimal(2, 1)
);

ALTER TABLE exercises_workouts
ALTER COLUMN rest_time_mins
SET DEFAULT 0;