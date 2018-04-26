Rails.application.routes.draw do

  #=== KUBERNETES ROUTES ===#
    
  get '/_health', to: 'application#health'
  
  #=== CLEARANCE RELATED ROUTES ===#

  resources :users, controller: 'users', only: [:create, :new, :index, :edit, :update, :destroy] do
    resource :password,
      controller: 'clearance/passwords',
      only: [:create, :edit, :update]
  end

  resources :passwords, controller: 'clearance/passwords', only: [:create, :new]
  resource :session, controller: 'clearance/sessions', only: [:create]
  
  get '/sign_in' => 'clearance/sessions#new', as: 'sign_in'
  delete '/sign_out' => 'clearance/sessions#destroy', as: 'sign_out'

  #=== APP ROUTES ===#

  root :to => 'root#home'

  get '/settings' => 'settings#show', as: 'settings'
  get '/settings/edit' => 'settings#edit', as: 'edit_settings'
  put '/settings' => 'settings#update'

end
