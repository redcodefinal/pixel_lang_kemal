require "kemal"
require "pixel_lang_crystal"
require "./programs"

engines = [] of AutoEngine

Programs.load

get "/" do
  render "src/views/main.ecr"
end

get "/engines/:e_id" do |env|
  e_id = env.params.url["e_id"].to_i
  engine = engines[e_id]
  render "src/views/engine.ecr"
end

get "/engines/:e_id/next" do |env|
  e_id = env.params.url["e_id"].to_i
  engine = engines[e_id]
  engine.run_one_instruction
  env.redirect "/engines/#{e_id}"
end

post "/engines/new" do |env|
  engines << AutoEngine.new env.params.body["name"], env.params.body["program"], env.params.body["input"]
  env.redirect "/"
end

get "/engines/:e_id/instructions/:x/:y" do |env|
  x = env.params.url["x"].to_i
  y = env.params.url["y"].to_i
  e_id = env.params.url["e_id"].to_i
  engine = engines[e_id]
  render "src/views/instruction.ecr"
end

get "/engines/:e_id/pistons" do
end

get "/engines/:e_id/pistons/:p_id" do
end

Kemal.run