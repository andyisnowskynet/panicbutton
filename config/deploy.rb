require 'bundler/capistrano'
after "deploy:symlink", "deploy:symlink_configs"
after "deploy:symlink", "deploy:symlink_htaccess"
# after "deploy:symlink", "deploy:symlink_dirs"
# after "deploy:symlink", "deploy:compile_sass"

set :user, "rubypan"
set :domain, "http://216.157.102.20/~rubypan/"
set :application, "panicbutton"
set :repository,  "git@github.com:andyisnowskynet/panicbutton.git"
set :deploy_to, "~/#{application}"

set :scm, :git
set :scm_passphrase, ""
set :scm_verbose, true
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
#set :deploy_via, :remote_cache

set :keep_releases, 2


set :rails_env,  "production"



role :web, "216.157.102.20"
role :app, "216.157.102.20"
role :db,  "216.157.102.20", :primary => true


namespace :deploy do
  task :symlink_configs, :role => :app do
    %w(settings.yml database.yml).each do |filename|
      run "ln -nfs #{shared_path}/#{filename} #{release_path}/config/#{filename}"
    end
  end
  
  # desc "Update CSS files and replace relative urls with absolute ones"
  # task :compile_sass, :roles => :app do
  #   haml_dir = 'haml'
  #   run "ls #{current_path}/vendor/gems | grep haml" do |channel, stream, data|
  #     haml_dir = data
  #   end
  #   run <<-BASH
  #     for file in #{current_path}/public/stylesheets/sass/*.sass; do
  #       #{current_path}/vendor/gems/#{haml_dir}/bin/sass $file #{current_path}/public/stylesheets/`basename ${file%.sass}`.css ; done
  #   BASH
  # end
  
  
  task :symlink_htaccess, :role => :app do
    run "ln -s #{shared_path}/.htaccess #{release_path}/public/.htaccess"
  end
  
  # desc "Symlink persisted directories"
  # task :symlink_dirs, :roles => :app, :except => { :no_symlink => true } do
  #   # this is a little weird, we can't just link public/images because that's
  #   # in the repo, but the Image model is also a dynamic upload path, so we're
  #   # pre-linking a bunch of possible dynamic folder destinations, add more if
  #   # necessary...
  #   %w( tmp/milton public/assets).each do |directory|
  #     run "mkdir -p #{shared_path}/#{directory}"
  #     run "ln -nfs #{shared_path}/#{directory} #{release_path}/#{directory}"
  #   end
  # end    
  
  %w(start restart).each { |name| task name, :roles => :app do passenger.restart end }
end

namespace :passenger do
  desc "Restart Application"
  task :restart, :roles => :app do
  run "touch #{current_path}/tmp/restart.txt"
  end
end


desc "Restart the web server. Overrides the default task for Site5 use."
task :restart, :roles => :app do
  run "killall -q dispatch.fcgi"
  run "chmod 755 #{current_path}/public/dispatch.fcgi"
  run "touch #{current_path}/public/dispatch.fcgi"
end
