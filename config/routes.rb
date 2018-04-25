Rails.application.routes.draw do

  root :to => 'root#home'

  #=== KUBERNETES ROUTES ===#
    
  get '/_health', to: 'application#health'
  
  #=== CLEARANCE RELATED ROUTES ===#

  constraints Clearance::Constraints::SignedIn.new do
    resources :users, controller: 'users', only: [:create, :new, :index, :edit, :update, :destroy] do
      resource :password,
        controller: 'clearance/passwords',
        only: [:create, :edit, :update]
    end
  
    delete '/sign_out' => 'clearance/sessions#destroy', as: 'sign_out'
  end

  resources :passwords, controller: 'clearance/passwords', only: [:create, :new]
  resource :session, controller: 'clearance/sessions', only: [:create]
  get '/sign_in' => 'clearance/sessions#new', as: 'sign_in'

  #=== APP ROUTES ===#

end
