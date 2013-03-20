require "rvm/capistrano"
set :rvm_type, :system

require 'bundler/capistrano'

set :application, "pre.writings.io"
set :repository,  "rei@chloerei.com:git/publish-design"
set :scm, "git"
set :branch, "upload"
#set :deploy_via, :remote_cache

set :user, "webuser"
set :deploy_to, "/home/webuser/#{application}"
set :use_sudo, false

role :web, "chloerei.com"
role :app, "chloerei.com"
role :db,  "chloerei.com", :primary => true

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
