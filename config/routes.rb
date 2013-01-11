Publish::Application.routes.draw do
  constraints :host => APP_CONFIG["host"] do
    root :to => 'dashboard/articles#index'
    get 'signup' => 'users#new', :as => :signup
    get 'login' => 'user_sessions#new', :as => :login
    delete 'logout' => 'user_sessions#destroy', :as => :logout

    resources :users, :only => [:create]
    resources :user_sessions, :only => [:create]

    scope :module => 'dashboard', :as => 'dashboard' do
      root :to => 'articles#index'
      get '(:status)', :to => 'articles#index', :constraints => { :status => /publish|draft|trash/ }, :as => :all_articles
      get 'books/:book_id(/:status)', :to => 'articles#book', :constraints => { :status => /publish|draft|trash/ }, :as => :book_articles
      get 'not_collected(/:status)', :to => 'articles#not_collected', :constraints => { :status => /publish|draft|trash/ }, :as => :not_collected_articles

      delete 'trash', :to => 'articles#empty_trash'

      resource :profile, :only => [:show, :update]
      resource :account, :only => [:show, :update, :destroy]

      resources :books, :only => [:new, :create, :edit, :update, :destroy], :path_names => { :edit => :settings } do
      end
      resources :articles, :only => [:new, :create, :edit, :update, :destroy] do
        collection do
          post :bulk
        end
      end
    end
  end

  if Rails.env.development?
    resource :ui, :controller => 'ui', :only => [:show] do
      collection do
        get :book
        get :editor
        get :form
        get :modal
        get :site_home
      end
    end
  end
end
