module Shopify
  class AfterAuthenticateJob < ActiveJob::Base
    def perform(shop_domain:)
      shop = Shop.find_by(shopify_domain: shop_domain)
      # puts ShopifyAPI::Shop.current.inspect
      shop.with_shopify_session do
        puts "*****************"
        puts "*****************"
        puts "*****************"
        puts shop.inspect
        puts "*****************"
      end
    end
  end
end
