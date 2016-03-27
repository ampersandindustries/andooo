Doubleunion::Application.routes.draw do
  root to: 'static_pages#home'

  get 'code_of_conduct' => 'static_pages#code_of_conduct'
  get 'details' => 'static_pages#details'

  namespace :members do
    root to: 'users#index'

    resources :users, only: [:index, :show] do
      get 'setup' => "users#setup"
      patch 'setup' => "users#finalize"

      resource :dues, only: [:show, :update]
    end
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
    resources :memberships, only: [:index, :update]
    patch "memberships/:id/change_membership_state" => "memberships#change_membership_state", as: "change_membership_state"
  end

  get 'admin/new_members' => 'admin#new_members'
  get 'admin/applications' => 'admin#applications'
  get 'admin/dues' => 'admin#dues'

  patch 'admin/approve' => 'admin#approve'
  patch 'admin/reject' => 'admin#reject'

  post 'admin/setup_complete' => 'admin#setup_complete'
  post 'admin/save_membership_note' => 'admin#save_membership_note'

  resources :applications, only: [:show, :edit, :update]
  resource :attendances, only: [:new, :create] do
    get :details, on: :member
    get :payment_form
    put :pay
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
