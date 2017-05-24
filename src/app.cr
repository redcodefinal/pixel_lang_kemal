require "kemal"
require "pixel_lang_crystal"
require "./programs"

engines = {} of String => AutoEngine
engines["hello_world"] = AutoEngine.new("hello_world", "./public/programs/basic/hello_world.png")
Programs.load

running = false
ZOOMS = [0.075, 0.125, 0.15, 0.2, 0.25, 0.3, 0.4, 0.5, 0.65, 0.75, 0.85, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 3.5, 4.0, 5.0]
zoom = 1.0

get "/" do
  running = false
  render "src/views/main.ecr"
end

get "/zoom/in" do |env|
  running = false
  zoom_i = ZOOMS.index(zoom).as(Int32)
  zoom = ZOOMS[zoom_i+1] unless zoom_i == ZOOMS.size-1
  puts zoom
  env.redirect env.request.headers["Referer"]
end

get "/zoom/out" do |env|
  running = false
  zoom_i = ZOOMS.index(zoom).as(Int32)
  zoom = ZOOMS[zoom_i-1] unless zoom_i == 0
  puts zoom
  env.redirect env.request.headers["Referer"]
end

get "/engines/:e_id" do |env|
  e_id = env.params.url["e_id"]
  engine = engines[e_id]
  if running
    running = false if engine.ended?
    engine.run_one_instruction
  end
  render "src/views/engine.ecr"
end

get "/engines/:e_id/delete" do |env|
  running = false
  e_id = env.params.url["e_id"]
  engines.delete e_id 
  env.redirect env.request.headers["Referer"]
end

post "/engines/:e_id/next" do |env|
  running = false
  e_id = env.params.url["e_id"]
  cycles = env.params.body["cycles"].to_i
  engine = engines[e_id]
  cycles.times {engine.run_one_instruction}
  env.redirect env.request.headers["Referer"]
end

get "/engines/:e_id/reset" do |env|
  running = false
  e_id = env.params.url["e_id"]
  engine = engines[e_id]
  engine.reset
  env.redirect env.request.headers["Referer"]
end

get "/engines/:e_id/run" do |env|
  running = false
  e_id = env.params.url["e_id"]
  engine = engines[e_id]
  engine.run
  env.redirect env.request.headers["Referer"]
end

get "/engines/:e_id/play" do |env|
  e_id = env.params.url["e_id"]
  engine = engines[e_id]
  running = true 
  env.redirect env.request.headers["Referer"]
end

get "/engines/:e_id/stop" do |env|
  e_id = env.params.url["e_id"]
  engine = engines[e_id]
  running = false 
  env.redirect env.request.headers["Referer"]
end

post "/engines/new" do |env|
  running = false
  program_name = env.params.body["program_name"]
  if program_name == ""
    env.redirect "/"
  end  
  engines[program_name] = AutoEngine.new program_name, env.params.body["program"], env.params.body["input"]
  env.redirect env.request.headers["Referer"]
end

get "/engines/:e_id/instructions/:x/:y" do |env|
  running = false
  x = env.params.url["x"].to_i
  y = env.params.url["y"].to_i
  e_id = env.params.url["e_id"]
  engine = engines[e_id]
  pistons = engine.pistons.select {|p| p.position_x == x && p.position_y == y}
  render "src/views/instruction.ecr"
end

get "/engines/:e_id/pistons" do
end

get "/engines/:e_id/pistons/:p_id" do
end

Kemal.run