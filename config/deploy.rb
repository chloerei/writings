require "rvm/capistrano"
set :rvm_type, :user

require 'bundler/capistrano'

set :application, "writings.io"
set :repository,  "rei@chloerei.com:git/publish-design"
set :scm, "git"
set :branch, "master"
set :deploy_via, :remote_cache

set :user, "rei"
set :deploy_to, "/home/rei/#{application}"
set :use_sudo, false

role :web, "66.228.49.5"
role :app, "66.228.49.5"
role :db,  "66.228.49.5", :primary => true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :copy_config do
    run "cp #{deploy_to}/shared/config/*.yml #{release_path}/config"
  end
end

after "deploy:update_code", "deploy:copy_config"
load 'deploy/assets'
