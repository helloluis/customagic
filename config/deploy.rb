set :application, "customagic"
set :repository,  "git@github.com:helloluis/customagic.git"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "162.243.146.215"                          # Your HTTP server, Apache/etc
role :app, "162.243.146.215"                          # This may be the same as your `Web` server
role :db,  "162.243.146.215", :primary => true # This is where Rails migrations will run
role :db,  "162.243.146.215"

set :default_stage, "staging"
set :deploy_to,     "/var/apps/#{application}"
set :scm,           :git
set :keep_releases, 3
set :branch,        "staging"
set :deploy_via,    :remote_cache

set :user,          "deploy"
set :sudo_user,     "deploy"
set :use_sudo,      false
set :ssh_options,   { :forward_agent => true }
set :rails_env,     "staging"
default_run_options[:pty] = true

# set :shared_children, %w(system log pids scripts sockets)
set :log_files,   %w(unicorn.stderr.log unicorn.stdout.log resque-scheduler.log)

set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"

set :rvm_type, :system

require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require "rvm/capistrano"
# require 'sidekiq/capistrano'
require 'capistrano/nginx/tasks'
require 'capistrano-unicorn'
# require 'capistrano_colors'


# load 'deploy'
load 'deploy/assets'
# load 'config/deploy'
# load "config/deploy/extensions/db"

after "deploy", "deploy:cleanup"


# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "export PATH=/usr/local/rvm/bin:$PATH"
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    #put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  # task :symlink_config, roles: :app do
  #   run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  # end
  # after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end