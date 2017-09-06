class WebhookManagerController < ApplicationController
  include ShopifyApp::WebhookVerification

  def uninstall
    UninstallJob.perform_later( shop_domain, params.to_json)
    head :ok
  end

  def order_create
    puts "Order Created"
    puts params.to_json
    CreateJob.perform_later(shop_domain, params.to_json)
  end
end
