ShopifyApp.configure do |config|
  config.application_name = "Printex Shopify App"
  config.api_key = "d9f3d508e72f69020b0e1ce12366e11b"
  config.secret = "7a978cc885a34979a35cc6d2f73db241"
  config.scope = "read_orders, write_orders, read_products, write_products, read_script_tags, write_script_tags, read_content, write_content"
  config.embedded_app = true
  config.after_authenticate_job = false
  config.session_repository = Shop
  config.after_authenticate_job = { job: Shopify::AfterAuthenticateJob, inline: false }
  config.webhooks = [
    {topic: 'orders/paid', address: 'https://shopify.printexinc.com/webhooks/order/create', format: 'json'}
    # {topic: 'app/uninstalled', address: 'https://24e3843d.ngrok.io/webhooks/uninstall/', format: 'json'}
  ]
end
