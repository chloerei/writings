require "rvm/capistrano"
set :rvm_type, :system

require 'bundler/capistrano'

set :application, "writings.io"
set :repository,  "git://chloerei.com:git/publish-design"

role :web, "codecampo.com"
role :app, "codecampo.com"
role :db,  "codecampo.com", :primary => true

set :user, "webuser"
set :deploy_to, "~/#{application}"
set :use_sudo, false

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :copy_config do
    run "cp #{deploy_to}/shared/config/*.yml #{release_path}/config"
  end
end

after "deploy:update_code", "deploy:copy_config"
load 'deploy/assets'
