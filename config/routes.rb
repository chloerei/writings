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

Publish::Application.routes.draw do
  constraints :host => APP_CONFIG["host"] do
    root :to => 'home#index'
    get 'signup' => 'users#new', :as => :signup
    get 'login' => 'user_sessions#new', :as => :login
    delete 'logout' => 'user_sessions#destroy', :as => :logout

    resources :users, :only => [:create]
    resources :user_sessions, :only => [:create]

    resource :account, :only => [:show, :update, :destroy]
    resource :billing, :only => [:show]

    resources :workspaces, :only => [:new, :create]

    scope '/~:space_id', :module => 'dashboard', :as => 'dashboard' do
      root :to => 'articles#index'

      resource :settings, :only => [:show, :update]
      resources :members, :only => [:index, :destroy]
      resources :invitations, :only => [:show, :accept, :create, :destroy] do
        member do
          put :resend
          put :accept
          post :join
        end
      end

      resources :categories, :only => [:create, :edit, :update, :destroy], :path_names => { :edit => :settings }
      get '(/category/:category_id)(/:status)', :as => 'articles_index', :to => 'articles#index', :constraints => { :status => /publish|draft/ }
      get '/trash', :as => 'articles_trash', :to => 'articles#trash_index'
      resources :articles, :only => [:new, :create, :edit, :update, :destroy] do
        collection do
          delete 'trash', :to => 'articles#empty_trash'
        end

        member do
          get :status
          put :category
          put :publish
          put :draft
          put :trash
          put :restore
          delete :destroy
        end

        resources :versions, :only => [:index, :show] do
          member do
            put :restore
          end
        end
      end
      resources :attachments, :only => [:index, :create, :destroy]

      resources :discussions, :only => [:index] do
        collection do
          get :archived
        end
      end
      resources :topics, :only => [:show, :new, :create, :edit, :update ,:destroy] do
        member do
          put :archive
          put :open
        end
      end
      resources :notes, :only => [:new, :create, :edit, :update, :destroy] do
        member do
          put :archive
          put :open
        end
      end
      resources :comments, :only => [:create, :edit, :update, :destroy]
    end

    constraints(AdminConstraint) do
      namespace :admin do
        root :to => 'dashboard#show'
        resources :articles, :only => [:index, :show]
        resources :users, :only => [:index, :show]
        resources :workspaces, :only => [:index, :show]
        resources :invoices, :only => [:index, :show, :new, :create, :destroy] do
          member do
            put :approve
          end
        end
      end

      mount Sidekiq::Web => '/sidekiq'
    end
  end

  constraints(Sitedomain) do
    scope :module => 'site', :as => 'site' do
      root :to => 'articles#index'
      get 'feed', :to => 'articles#feed', :as => :feed
      get 'articles/:id(-:urlname)', :to => 'articles#show', :as => :article, :constraints => { :id => /[a-zA-Z0-9]+/ }
      resources :categories, :only => [:index, :show] do
        member do
          get :feed
        end
      end
    end
  end

  if Rails.env.development?
    namespace :ui do
      get 'dashboard/:action', :controller => 'dashboard'
      get 'site/:action', :controller => 'site'
    end
  end

  if Rails.env.production?
    match '*a', :to => 'errors#not_found'
  end
end
