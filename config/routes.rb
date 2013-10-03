require 'sidekiq/web'

class AdminConstraint
  def self.matches?(request)
    return false unless request.session[:user_id]
    user = User.find request.session[:user_id]
    user && user.admin?
  end
end

class Sitedomain
  def self.matches?(request)
    request.host =~ /^[a-zA-Z0-9\-]+\.#{Regexp.escape APP_CONFIG["host"]}$/ or request.host !~ /#{Regexp.escape APP_CONFIG["host"]}$/
  end
end

Writings::Application.routes.draw do
  constraints :host => APP_CONFIG["host"] do
    root :to => 'home#index'
    get 'signup' => 'users#new', :as => :signup
    get 'login' => 'user_sessions#new', :as => :login
    delete 'logout' => 'user_sessions#destroy', :as => :logout

    resources :password_resets, :only => [:new, :create, :edit, :update]

    resources :users, :only => [:create]
    resources :user_sessions, :only => [:create]

    resource :account, :only => [:show, :update]

    resources :invoices, :only => [:index, :new, :create, :show, :destroy] do
      collection do
        post :alipay_notify
      end
    end
    resources :spaces, :only => [:new, :create]

    scope '/~:space_id', :module => 'dashboard', :as => 'dashboard' do
      root :to => 'articles#index'

      resource :billing, :only => [:show]
      resources :orders, :only => [:index, :new, :create, :show, :destroy] do
        collection do
          post :alipay_notify
        end
      end

      resource :settings, :only => [:show, :update]
      resources :members, :only => [:index, :destroy]
      resources :invitations, :only => [:show, :accept, :create, :destroy] do
        member do
          put :resend
          put :accept
          post :join
        end
      end

      get '/trashed', :as => 'articles_trashed', :to => 'articles#trashed'
      resources :articles, :only => [:new, :show, :create, :edit, :update, :destroy] do
        collection do
          delete 'trashed', :to => 'articles#empty_trash'
          put :batch_trash
          put :batch_publish
          put :batch_draft
          put :batch_restore
          put :batch_destroy
        end

        member do
          get :status
          put :restore
        end

        resources :versions, :only => [:index, :show] do
          member do
            put :restore
          end
        end
      end

      resources :export_tasks, :only => [:index, :create, :show] do
        member do
          get :download
        end
      end
      resources :import_tasks, :only => [:index, :create, :show, :destroy] do
        member do
          post :confirm
        end
      end
      resources :attachments, :only => [:index, :create, :destroy]
    end

    constraints(AdminConstraint) do
      namespace :admin do
        root :to => 'dashboard#show'
        resources :articles, :only => [:index, :show]
        resources :users, :only => [:index, :show]
        resources :spaces, :only => [:index, :show]
        resources :attachments, :only => [:index]
        resources :orders, :only => [:index, :show]
        resources :alipay_notifies, :only => [:index, :show]
      end

      mount Sidekiq::Web => '/sidekiq'
    end
  end

  constraints(Sitedomain) do
    scope :module => 'site', :as => 'site' do
      root :to => 'articles#index'
      get 'feed', :to => 'articles#feed', :as => :feed
      get 'articles/:id(-:urlname)', :to => 'articles#show', :as => :article, :constraints => { :id => /[a-zA-Z0-9]+/ }
      resources :authors, :only => [:index, :show]
      resources :archives, :only => [:index]
    end
  end

  if Rails.env.development?
    namespace :ui do
      get 'dashboard/:action', :controller => 'dashboard'
      get 'site/:action', :controller => 'site'
    end
  end

  if Rails.env.production?
    get '*a', :to => 'errors#not_found'
  end
end
