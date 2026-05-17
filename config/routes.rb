# frozen_string_literal: true

Railswatch::Engine.routes.draw do
  get '/' => 'railswatch#index', :as => :railswatch

  get '/requests' => 'railswatch#requests', :as => :railswatch_requests
  get '/crashes' => 'railswatch#crashes', :as => :railswatch_crashes
  get '/recent' => 'railswatch#recent', :as => :railswatch_recent
  get '/slow' => 'railswatch#slow', :as => :railswatch_slow

  get '/trace/:id' => 'railswatch#trace', :as => :railswatch_trace
  get '/summary' => 'railswatch#summary', :as => :railswatch_summary

  get '/sidekiq' => 'railswatch#sidekiq', :as => :railswatch_sidekiq
  get '/delayed_job' => 'railswatch#delayed_job', :as => :railswatch_delayed_job
  get '/grape' => 'railswatch#grape', :as => :railswatch_grape
  get '/rake' => 'railswatch#rake', :as => :railswatch_rake
  get '/custom' => 'railswatch#custom', :as => :railswatch_custom
  get '/resources' => 'railswatch#resources', :as => :railswatch_resources
end

Rails.application.routes.draw do
  mount Railswatch::Engine => Railswatch.mount_at, :as => 'railswatch'
rescue ArgumentError
  # already added
  # this code exist here because engine not includes routing automatically
end
