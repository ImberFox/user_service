Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/user/', to: 'user#index'
  post '/get_user/', to: 'user#get_user'
  post '/create_user/', to: 'user#create_user'
end
