require "kemal"
require "pixel_lang_crystal"
require "./programs"

engines = {} of String => AutoEngine
engines["hello_world"] = AutoEngine.new("hello_world", "./public/programs/basic/hello_world.png")
engines["euler_2"] = AutoEngine.new("euler_2", "./public/programs/euler/2.png", "10")

Programs.load

# Whether or not the current engine is playing.
playing = false

ZOOMS = [0.075, 0.125, 0.15, 0.2, 0.25, 0.3, 0.4, 0.5, 0.65, 0.75, 0.85, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 3.5, 4.0, 5.0]
zoom = 1.0

# Displays main page
get "/" do
  playing = false
  render "src/views/main.ecr"
end

# Zooms in, then returns to sender
get "/zoom/in" do |env|
  playing = false
  zoom_i = ZOOMS.index(zoom).as(Int32)
  zoom = ZOOMS[zoom_i+1] unless zoom_i == ZOOMS.size-1
  puts zoom
  env.redirect env.request.headers["Referer"]
end

# Zooms out, then returns to sender
get "/zoom/out" do |env|
  playing = false
  zoom_i = ZOOMS.index(zoom).as(Int32)
  zoom = ZOOMS[zoom_i-1] unless zoom_i == 0
  puts zoom
  env.redirect env.request.headers["Referer"]
end

# Displays an engine based on its e_id(Engine#name)
#    this also displays the instructions on a grid.
get "/engines/:e_id" do |env|
  e_id = env.params.url["e_id"]
  engine = engines[e_id]
  if playing
    playing = false if engine.ended?
    engine.run_one_instruction
  end
  render "src/views/engine.ecr"
end

# Deletes an engine then, returns to sender.
# TODO: change method from get to delete but couldnt get it to work.
get "/engines/:e_id/delete" do |env|
  playing = false
  e_id = env.params.url["e_id"]
  engines.delete e_id 
  env.redirect env.request.headers["Referer"]
end

# Runs an engine for the number of cycles specified then, returns to sender.
post "/engines/:e_id/next" do |env|
  playing = false
  e_id = env.params.url["e_id"]
  cycles = env.params.body["cycles"].to_i
  engine = engines[e_id]
  cycles.times {engine.run_one_instruction}
  env.redirect env.request.headers["Referer"]
end

# Resets an engine, then returns to sender
get "/engines/:e_id/reset" do |env|
  playing = false
  e_id = env.params.url["e_id"]
  engine = engines[e_id]
  engine.reset
  env.redirect env.request.headers["Referer"]
end

# Runs an engine, then returns to sender
get "/engines/:e_id/run" do |env|
  playing = false
  e_id = env.params.url["e_id"]
  engine = engines[e_id]
  engine.run
  env.redirect env.request.headers["Referer"]
end

# Begins playing the engine, enabling auto refresh and performing run_one_instruction, then returns to sender
get "/engines/:e_id/play" do |env|
  e_id = env.params.url["e_id"]
  engine = engines[e_id]
  playing = true 
  env.redirect env.request.headers["Referer"]
end

# Stops the engine from playing anymore, disabling auto refresh and run_one_instruction, then returns to sender.
get "/engines/:e_id/stop" do |env|
  e_id = env.params.url["e_id"]
  engine = engines[e_id]
  playing = false 
  env.redirect env.request.headers["Referer"]
end

# Makes a new engine
post "/engines/new" do |env|
  playing = false
  program_name = env.params.body["program_name"]
  if program_name == ""
    env.redirect "/"
  end  
  engines[program_name] = AutoEngine.new program_name, env.params.body["program"], env.params.body["input"]
  env.redirect env.request.headers["Referer"]
end

# Displays an instruction, and the current pistons on that instruction.
get "/engines/:e_id/instructions/:x/:y" do |env|
  playing = false
  x = env.params.url["x"].to_i
  y = env.params.url["y"].to_i
  e_id = env.params.url["e_id"]
  engine = engines[e_id]
  pistons = engine.pistons.select {|p| p.position_x == x && p.position_y == y}
  render "src/views/instruction.ecr"
end

Kemal.run