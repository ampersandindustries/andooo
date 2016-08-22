Doubleunion::Application.routes.draw do
  root to: 'static_pages#home'

  get 'code_of_conduct' => 'static_pages#code_of_conduct'
  get 'details' => 'static_pages#details'
  get 'accessibility' => 'static_pages#accessibility'
  get 'andxp' => 'static_pages#andxp'

  resource :donations, only: [:show, :create]

  namespace :volunteers do
    root to: 'users#index'

    resources :users, only: [:index, :show]
    resources :votes, only: [:create, :destroy]

    resources :applications, only: [:index, :show] do
      resources :comments, only: :create
    end

    resources :caches, only: :index do
      post :expire, on: :collection
    end
  end

  namespace :admin do
    resource :exceptions, only: :show
    resources :attendees, only: [:index, :update, :show]
  end

  get 'admin/applications' => 'admin#applications'

  patch 'admin/approve' => 'admin#approve'
  patch 'admin/reject' => 'admin#reject'
  post 'admin/save_membership_note' => 'admin#save_membership_note'

  resources :applications, only: [:show, :edit, :update]
  resource :attendances, only: [:new, :create, :edit, :update] do
    get :details, on: :member
    get :payment_form
    put :pay
    get :scholarship_form
    put :confirm_scholarship
    put :decline
  end

  get 'auth/:provider/callback' => 'sessions#create'
  get 'github_login' => 'sessions#github'
  get 'google_login' => 'sessions#google'
  get 'login' => 'sessions#login'
  get 'logout' => 'sessions#destroy'
  get 'auth/failure' => 'sessions#failure'
  get 'get_email' => 'sessions#get_email'
  post 'confirm_email' => 'sessions#confirm_email'

  post 'add_github_auth' => 'authentications#add_github_auth'
  post 'add_google_auth' => 'authentications#add_google_auth'

  get 'configurations' => 'api#configurations'

  mount StripeEvent::Engine => '/stripe'
end
