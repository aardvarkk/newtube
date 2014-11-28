Newtube::Application.routes.draw do
  
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root to: 'users#show'

  match 'user/edit' => 'users#edit', as: :edit_current_user

  match 'signup' => 'users#new', as: :signup

  match 'logout' => 'sessions#destroy', as: :logout

  match 'login' => 'sessions#new', as: :login

  resources :sessions

  resources :users do
    collection do
      get 'search_show'
    end
  end

  match 'user/add_show' => 'users#add_show', as: :add_show

  match 'user/remove_show' => 'users#remove_show', as: :remove_show

  match 'user/set_show_status' => 'users#set_show_status', as: :set_show_status, via: :post

  match 'user/update_show' => 'users#update_show', as: :update_show
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
