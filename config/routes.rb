Contentment::Application.routes.draw do
  root :to => 'contentment#chooser', :as => 'beginning'
  match 'record/:data', :to => 'contentment#record', :as => 'record'

  scope '/system' do
    root :to => 'contentment#index', :as => 'home'
    match 'clients', :to => 'contentment#clients', :as => 'clients'
    match 'get_latest/:code/:version/:status', :to => 'contentment#update', :as => 'client_update'
    match 'client_download/:code/:version.:format', :to => 'contentment#client_download', :as => 'client_download'
    match 'auth(/:who)', :to => 'contentment#auth', :as => 'auth'
    match 'publisher(/:id)', :to => 'contentment#publisher', :as => 'publisher'
    match 'application/:id', :to => 'contentment#application', :as => 'application'
    match 'messaging(/:dest)', :to => 'contentment#messaging', :as => 'messaging'
    match 'users(/:userid)', :to => 'contentment#users', :as => 'users'
    match 'tag(/:name)', :to => 'contentment#tags', :as => 'tag'

    match 'destroy/:app', :to => 'contentment#destroy_app', :as => 'destroy_app', :via => :post
    match 'create_app', :to => 'contentment#create_app', :as => 'app_create', :via => :post
    match 'upload_client', :to => 'contentment#upload_client', :as => 'client_upload', :via => :post
    match 'update_publisher/:id', :to => 'contentment#update_publisher', :as => 'update_publisher', :via => :post
    match 'update_application/:id', :to => 'contentment#update_application', :as => 'update_application', :via => :post
    match 'create_publisher', :to => 'contentment#create_publisher', :as => 'publisher_create', :via => :post
    match 'delete_publisher/:id', :to => 'contentment#delete_publisher', :as => 'publisher_delete', :via => :post
    match 'delete_application/:id', :to => 'contentment#delete_application', :as => 'application_delete', :via => :post
  end

  scope '/data' do
    root :to => 'statistics#index', :as => 'data'
  end

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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
