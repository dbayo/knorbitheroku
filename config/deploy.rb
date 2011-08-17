set :application, "knorbit"
set :domain,      "174.129.21.182"
set :repository,  "git://github.com/knorbit/WN.git"
set :use_sudo,    false

set :scm,         "git"

role :web, "174.129.21.182"                          # Your HTTP server, Apache/etc
role :app, "174.129.21.182"                          # This may be the same as your `Web` server
role :db,  "localhost", :primary => true # This is where Rails migrations will run


# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end