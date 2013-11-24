set :rails_env,   "staging"
set :unicorn_env, "staging"
set :app_env,     "staging"
set :whenever_environment, "staging"

set :branch,      "master"

server "162.243.146.215", :app, :web, :db, :worker, primary: true
