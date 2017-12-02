Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/user/', to: 'user#index'
  get '/status/', to: 'user#status', :as => :status
  post '/get_user/', to: 'user#get_user', :as => :get_user
  post '/create_user/', to: 'user#create_user', :as => :create_user
end
