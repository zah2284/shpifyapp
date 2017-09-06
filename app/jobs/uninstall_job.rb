class UninstallJob < ActiveJob::Base
  def perform(shop_domain, webhook)
    shop = Shop.find_by_shopify_domain( shop_domain)

    shop.with_shopify_session do
      shop.products.each do |product|
        product.destroy
      end
      shop.destroy
    end
  end
end
