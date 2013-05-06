class Sitedomain
  def matches?(request)
    request.host =~ /^\w+\.#{Regexp.escape APP_CONFIG["host"]}$/ or request.host !~ /#{Regexp.escape APP_CONFIG["host"]}$/
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

    resource :profile, :only => [:show, :update]
    resource :account, :only => [:show, :update, :destroy]
    resource :billing, :only => [:show]

    resources :workspaces, :only => [:new, :create]

    scope '/~:space_id', :module => 'dashboard', :as => 'dashboard' do
      root :to => 'dashboard#show'

      resource :settings, :only => [:show, :update]
      resources :members, :only => [:index]
      resources :invitations, :only => [:create, :destroy]

      resources :categories, :only => [:create, :edit, :update, :destroy], :path_names => { :edit => :settings }
      resources :articles, :only => [:index, :new, :create, :edit, :update, :destroy] do
        collection do
          get '(/category/:category_id)(/:status)', :as => 'index', :action => 'index', :constraints => { :status => /publish|draft/ }
          post :bulk
          get 'trash', :to => 'articles#trash_index'
          delete 'trash', :to => 'articles#empty_trash'
        end

        member do
          put :trash
          put :restore
        end

        resources :versions, :only => [:index, :show] do
          member do
            put :restore
          end
        end
      end
      resources :attachments, :only => [:index, :show, :create, :destroy]
    end

    namespace :admin do
      root :to => 'dashboard#show'
      resources :articles, :only => [:index, :show]
      resources :users, :only => [:index, :show]
      resources :invoices, :only => [:index, :show, :new, :create, :destroy] do
        member do
          put :approve
        end
      end
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

  match '*a', :to => 'errors#not_found'
end
