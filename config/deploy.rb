require "bundler"
Bundler.setup(:default, :deployment)

# deploy recipes - need to do `sudo gem install thunder_punch` - these should be required last
require 'thunder_punch'

#############################################################
# Set Basics
#############################################################
set :application, "fr2_audit"
set :user, "deploy"

if File.exists?(File.join(ENV["HOME"], ".ssh", "fr_staging"))
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "fr_staging")]
else
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]
end

ssh_options[:paranoid] = false
set :use_sudo, true
default_run_options[:pty] = true

set(:current_path)    { "/var/www/apps/#{application}" }

set(:latest_release)  { fetch(:current_path) }
set(:release_path)    { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }
set(:shared_path)     { fetch(:current_path) }

set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }


set :finalize_deploy, false
# we don't need this because we have an asset server
# and we also use varnish as a cache server. Thus 
# normalizing timestamps is detrimental.
set :normalize_asset_timestamps, false


set :migrate_target, :current


#############################################################
# General Settings  
#############################################################

set :deploy_to,  "/var/www/apps/#{application}" 

#############################################################
# Set Up for Production Environment
#############################################################

task :production do
  set :rails_env,  "production"
  set :branch, 'production'
  
  role :proxy, "ec2-184-72-241-172.compute-1.amazonaws.com"
  role :app, "ec2-204-236-209-41.compute-1.amazonaws.com", "ec2-184-72-139-81.compute-1.amazonaws.com", "ec2-174-129-132-251.compute-1.amazonaws.com", "ec2-72-44-36-213.compute-1.amazonaws.com", "ec2-204-236-254-83.compute-1.amazonaws.com"
  role :db, "ec2-184-72-160-191.compute-1.amazonaws.com", {:primary => true}
  role :sphinx, "ec2-184-72-160-191.compute-1.amazonaws.com"
  role :static, "ec2-75-101-243-195.compute-1.amazonaws.com" #monster image
  role :worker, "ec2-75-101-243-195.compute-1.amazonaws.com", {:primary => true} #monster image
end


#############################################################
# Set Up for Staging Environment
#############################################################

task :staging do
  set :rails_env,  "staging" 
  set :branch, `git branch`.match(/\* (.*)/)[1]
  
  role :proxy,  "ec2-184-72-250-132.compute-1.amazonaws.com"
  role :app,    "ec2-50-19-14-105.compute-1.amazonaws.com"
  role :db,     "ec2-184-72-160-191.compute-1.amazonaws.com", {:primary => true}
  role :sphinx, "ec2-184-72-160-191.compute-1.amazonaws.com"
  role :static, "ec2-184-72-163-77.compute-1.amazonaws.com"
  role :worker, "ec2-184-72-163-77.compute-1.amazonaws.com", {:primary => true}
end


#############################################################
# SCM Settings
#############################################################
set :scm,              :git          
set :github_user_repo, 'criticaljuncture'
set :github_project_repo, 'fr2_audit'
set :deploy_via,       :remote_cache
set :repository, "git@github.com:#{github_user_repo}/#{github_project_repo}.git"
set :github_username, 'criticaljuncture' 


#############################################################
# Git
#############################################################

# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision, lambda { source.query_revision(revision) { |cmd| capture(cmd) } }
set :git_enable_submodules, true


#############################################################
# Bundler
#############################################################
# this should list all groups in your Gemfile (except default)
set :gem_file_groups, [:deployment, :development, :test]


#############################################################
# Run Order
#############################################################

# Do not change below unless you know what you are doing!
# all deployment changes that affect app servers also must 
# be put in the user-scripts files on s3!!!

after "deploy:update_code",            "deploy:set_rake_path"
after "deploy:set_rake_path",          "bundler:fix_bundle"
after "bundler:fix_bundle",            "passenger:restart"
# after "passenger:restart",             "deploy:notify_hoptoad"


#############################################################
#                                                           #
#                                                           #
#                         Recipes                           #
#                                                           #
#                                                           #
#############################################################

namespace :fr2_audit do
  desc "Update secret keys"
  task :update_secret_keys, :roles => [:app, :worker] do
    run "/usr/local/s3sync/s3cmd.rb get config.internal.federalregister.gov:fr2_audit_secrets.yml #{shared_path}/config/secrets.yml"
    find_and_execute_task("passenger:restart")
  end
  
  desc "Symlink mongoid.yml"
  task :symlink_mongoid_yml, :roles => [:app, :worker] do
    run "ln -sf /var/www/apps/fr2/current/config/mongoid.yml #{current_path}/config/mongoid.yml"
    find_and_execute_task("passenger:restart")
  end
end


######################################################################
# Define out own hoptoad notify so we can specify the server to be run on
######################################################################
namespace :deploy do
  desc "Notify Hoptoad of the deployment"
  task :notify_hoptoad, :except => { :no_release => true }, :roles => [:worker] do
    rails_env = fetch(:hoptoad_env, fetch(:rails_env, "production"))
    local_user = ENV['USER'] || ENV['USERNAME']
    executable = RUBY_PLATFORM.downcase.include?('mswin') ? fetch(:rake, 'rake.bat') : fetch(:rake, 'rake')
    notify_command = "#{executable} hoptoad:deploy TO=#{rails_env} REVISION=#{current_revision} REPO=#{repository} USER=#{local_user}"
    notify_command << " DRY_RUN=true" if dry_run
    notify_command << " API_KEY=#{ENV['API_KEY']}" if ENV['API_KEY']
    puts "Notifying Hoptoad of Deploy (#{notify_command})"
    run "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} #{notify_command}"
    puts "Hoptoad Notification Complete."
  end
end

