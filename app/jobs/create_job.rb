class CreateJob < ActiveJob::Base
  def perform(shop_domain, webhook)
    require 'json'

    @shop = Shop.find_by(shopify_domain: shop_domain)

    order = JSON.parse webhook
    order_date = DateTime.strptime(order["created_at"]).strftime("%m/%d/%Y")


    @shop.with_shopify_session do
      puts "****************************"
      puts "****************************"
      puts "****************************"
      puts "**************************** in session"

      get_line_items order
      fulfill_items order["id"]

      @order = {
        "order[0]" => {
          "order_number" => order["name"].sub!("#",""),
          "customer_name"  => order["shipping_address"]["first_name"],
          "last_name" => order["shipping_address"]["last_name"],
          "email" => order["email"],
          "street_address" => order["shipping_address"]["address1"],
          "city" => order["shipping_address"]["city"],
          "state" => order["shipping_address"]["state"],
          "zip" => order["shipping_address"]["zip"],
          "street_address_2" => order["shipping_address"]["address2"],
          "order_date" => order_date,
          "return_name" => "",
          "country" => order["shipping_address"]["country"],
          "OrderLineItems" => @line_items
        }
      }

      # puts "*********************"
      # puts "*********************"
      # puts "*********************"
      # puts "*********************"
      # puts @order.to_query


      # sending order to printex
      send_order_to_printex

    end
  end

  def fulfill_items( order_id )
    fulfillment = ShopifyAPI::Fulfillment.new
    fulfillment.prefix_options[:order_id] = order_id
    fulfillment.tracking_number = nil
    fulfillment.line_items = []

    for line_id in @line_items_ids
      fulfillment.line_items << { :id => line_id }
    end
    fulfillment.save
  end

  def send_order_to_printex
    require 'net/http'
    require 'uri'
    require 'json'

    uri = URI.parse("http://dev.lockerstock.printexinc.com/")
    header = {:Authorization =>  @shop.printex_token }

    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new("/api/orders", header)
    request.body = @order.to_query

    # Send the request
    response = http.request(request)

    puts response.inspect
    puts response
    puts response.body
  end

  def get_line_items( order )
    # checking printex line items
    @line_items_ids = []
    @line_items = {}

    i = 0
    for line_item in order["line_items"]
      product = nil
      product = ShopifyAPI::Product.find(line_item["product_id"])
      puts "***************"
      puts "***************"
      puts "***************"
      puts "***************"
      puts "***************"
      puts product
      if product != nil
        product_options = product.options.map { |o| o.name.downcase }
        variant = ShopifyAPI::Variant.find(line_item["variant_id"])
        product_vendor = product.vendor.downcase


        if product_vendor == "printex"
          # constructing line item
          @line_items[i] = {
            "item_id" => line_item["id"],
            "qty" => line_item["quantity"],
            "style" => line_item["name"]
          }
          option_counter = 1
          for option in product_options
            option_title = "option#{option_counter}"
            @line_items[i][option] = variant.send(option_title)
            option_counter = option_counter + 1
          end
          @line_items_ids << line_item["id"]
          i = i + 1
        end
      end
    end
  end
end
