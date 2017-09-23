class CreateJob < ActiveJob::Base
  def perform(shop_domain, webhook)
    require 'json'

    @shop = Shop.find_by(shopify_domain: shop_domain)

    order = JSON.parse webhook
    @order_arr_date = DateTime.strptime(order["created_at"]).strftime("%m/%d/%Y")
    @order_title = order["name"].sub!("#","")
    @shop.with_shopify_session do
      puts "****************************"
      puts "****************************"
      puts "****************************"
      puts "**************************** in session"


      line_ids = get_line_items order
      puts "line_ids here to inspect #{line_ids.inspect}"
      fulfill_items order["id"]
      # @order_arr = {
      #   "order[0]" => {
      #     "order_number" => order["name"].sub!("#",""),
      #     "customer_name"  => order["shipping_address"]["first_name"],
      #     "last_name" => order["shipping_address"]["last_name"],
      #     "email" => order["email"],
      #     "street_address" => order["shipping_address"]["address1"],
      #     "city" => order["shipping_address"]["city"],
      #     "state" => order["shipping_address"]["state"],
      #     "zip" => order["shipping_address"]["zip"],
      #     "street_address_2" => order["shipping_address"]["address2"],
      #     "order_date" => order_date,
      #     "return_name" => "",
      #     "country" => order["shipping_address"]["country"],
      #     "OrderLineItems" => @line_items
      #   }
      # }


      puts "*************order ((((((((((((****"
      puts @order_arr.inspect

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
    request.body = @order_arr.to_query

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

    @order_arr = {}
    i = 0
    for line_item in order["line_items"]
      @line_items = {}

      product = nil
      product_vendor = nil
      product = ShopifyAPI::Product.find(line_item["product_id"])

      if product != nil
        product_options = product.options.map { |o| o.name.downcase }
        variant = ShopifyAPI::Variant.find(line_item["variant_id"])
        product_vendor = product.vendor.downcase

        puts "product_vendor_checked #{product_vendor}"
        if product_vendor == "printex"
          puts "in the product vendor now #{product.title}"
          @line_items_ids << line_item["id"]
          # constructing line item
          product_db = @shop.products.find_by_product_id(product.id)
          @line_items[0] = {
            "item_id" => "#{@order_title}#{line_item["id"]}",
            "qty" => line_item["quantity"],
            "style" => line_item["name"],
            "art_url_front" => product_db.image
          }

          option_counter = 1
          for option in product_options
            option_title = "option#{option_counter}"
            @line_items[0][option] = variant.send(option_title)
            option_counter = option_counter + 1
          end


          @order_arr["order[#{i}]"] = {
            "order_number" => "#{@order_title}#{i}",
            "customer_name"  => order["shipping_address"]["first_name"],
            "last_name" => order["shipping_address"]["last_name"],
            "email" => order["email"],
            "street_address" => order["shipping_address"]["address1"],
            "city" => order["shipping_address"]["city"],
            "state" => order["shipping_address"]["state"],
            "zip" => order["shipping_address"]["zip"],
            "street_address_2" => order["shipping_address"]["address2"],
            "order_date" => @order_arr_date,
            "return_name" => "",
            "country" => order["shipping_address"]["country"],
            "OrderLineItems" => @line_items
          }

          i = i + 1
        end
      end
    end

    return @line_item_ids
  end
end
