Rails.application.routes.draw do
  root :to => 'home#index'

  mount ShopifyApp::Engine, at: '/'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # webhooks
  post '/webhooks/uninstall', :to => "webhook_manager#uninstall"
  post '/webhooks/order/create', :to => "webhook_manager#order_create"
  get '/settings' , :to => "home#settings", :as => "settings"
  patch '/settings/save_token', :to => "home#save_token", :as => "save_token"
  get '/settings/save_token', :to => "home#save_token"
  post '/home/signup', :to => "home#signup", :as => "create_account"
  # get '/add/product', :to => "product#add", :as => "add_product"
  # post '/add/product', :to => "product#save_product"
  # get '/remove/product/:id', :to => "product#remove", :as => "remove_product"
  get '/refresh', :to => "home#refresh_products", :as => "refresh_products"



end
