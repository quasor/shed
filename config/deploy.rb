set :application, "schedule.ectdev.com"
set :repository, "git@github.com:quasor/shed.git"
set :scm, :git

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end  
end

set :domain, "192.168.0.166"
role :web, domain
role :app, domain#, "192.168.0.166"
role :db,  domain, :primary => true
set :scm_command, "/usr/local/git/bin/git" 
# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
set :use_sudo, false
set :deploy_to, "/www/apps/#{application}" # defaults to "/u/apps/#{application}"
set :deploy_via, :remote_cache
set :user, "quasor"            # defaults to the currently logged in user


task :after_update_code, :roles => :app do
end
