Publish::Application.routes.draw do
  constraints :host => APP_CONFIG["host"] do
    root :to => "main#index"

    get 'signup' => 'users#new', :as => :signup
    resources :users, :only => [:create]
    get 'login' => 'user_sessions#new', :as => :login
    delete 'logout' => 'user_sessions#destroy', :as => :logout
    resources :user_sessions, :only => [:create]

    get 'account' => 'users#edit', :as => :account
    put 'account' => 'users#update'
    delete 'account' => 'users#destroy'
    resource :profile, :only => [:show, :update]

    resources :books, :only => [:show, :new, :create, :edit, :update, :destroy], :path_names => { :edit => :settings } do
      resources :articles, :only => [:new, :create]

      member do
        get :draft
      end
    end
    resources :articles, :only => [:show, :update, :destroy]
  end

  if Rails.env.development?
    resource :ui, :controller => 'ui', :only => [:show] do
      collection do
        get :book
        get :editor
        get :forum
        get :modal
      end
    end
  end
end
