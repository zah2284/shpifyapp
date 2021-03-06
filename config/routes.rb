Rails.application.routes.draw do
  root :to => 'home#index'

  # webhooks
  post '/webhooks/uninstall', :to => "webhook_manager#uninstall"
  post '/webhooks/order/create', :to => "webhook_manager#order_create"
  get '/settings' , :to => "home#settings", :as => "settings"
  patch '/settings/save_token', :to => "home#save_token", :as => "save_token"
  get '/settings/save_token', :to => "home#save_token"
  post '/home/signup', :to => "home#signup", :as => "create_account"
  get '/product/image/:id', :to => "product#choose_image", :as => "choose_image"
  get '/product/image_url/:id', :to => "product#enter_image_url", :as => "enter_image_url"
  post '/product/image/save', :to => "product#save_image", :as => "save_image"
  # get '/add/product', :to => "product#add", :as => "add_product"
  # post '/add/product', :to => "product#save_product"
  get '/remove/product/:id', :to => "product#remove", :as => "remove_product"
  get '/refresh', :to => "home#refresh_products", :as => "refresh_products"



  mount ShopifyApp::Engine, at: '/'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
