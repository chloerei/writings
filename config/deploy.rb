set :rvm_type, :user
require "rvm/capistrano"
require 'sidekiq/capistrano'
require 'bundler/capistrano'

set :application, "writings.io"
set :repository,  "git@github.com:chloerei/writings.git"
set :scm, "git"
set :branch, "master"

set :user, "rei"
set :deploy_to, "/home/rei/#{application}"
set :use_sudo, false

role :web, "writings.io"
role :app, "writings.io"
role :db,  "writings.io", :primary => true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :init_config do
    run "mkdir -p #{deploy_to}/shared/config"
    run "mkdir -p #{deploy_to}/shared/data"
  end

  task :copy_config do
    %w(mongoid.yml app_config.yml).each do |conf|
      run "test -f #{deploy_to}/shared/config/#{conf} || cp #{release_path}/config/#{conf}.example #{deploy_to}/shared/config/#{conf}"
    end

    run "cp #{deploy_to}/shared/config/*.yml #{release_path}/config"
  end

  # For import/export data
  task :link_data do
    run "ln -s #{deploy_to}/shared/data #{release_path}"
  end
end

after "deploy:setup", "deploy:init_config"
after "deploy:update_code", "deploy:copy_config", "deploy:link_data"

load 'deploy/assets'
