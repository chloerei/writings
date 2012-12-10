Publish::Application.routes.draw do
  constraints :host => APP_CONFIG["host"] do
    root :to => "main#index"

    get 'signup' => 'users#new', :as => :signup
    resources :users, :only => [:create]
    get 'login' => 'user_sessions#new', :as => :login
    delete 'logout' => 'user_sessions#destroy', :as => :logout
    resources :user_sessions, :only => [:create]

    resources :books, :only => [:show, :new, :create]
  end

  if Rails.env.development?
    resource :ui, :controller => 'ui', :only => [:show] do
      collection do
        get :book
        get :editor
        get :forum
      end
    end
  end
end
