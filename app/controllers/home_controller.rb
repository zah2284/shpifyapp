class HomeController < ShopifyApp::AuthenticatedController
  def index
    @thisshop = Shop.find_by_shopify_domain current_shopify_domain
    @filteredProd = @thisshop.products.reverse

    @signup = false
    if @thisshop.printex_token == nil || @thisshop.printex_token == ""
      @signup = true
    end

  end

  def signup
    @thisshop = Shop.find_by_shopify_domain current_shopify_domain
    puts "**********"
    puts "**********"
    puts "**********"

    acc =  account_params

    @account = {
      :name => acc["name"],
      :owner_name => acc["owner_name"],
      :email => acc["email"],
      :phone_number => acc["phone_number"],
      :payment_email => acc["email"],
      :international => acc[:international],
      :web_address => @thisshop.shopify_domain,
      :username => acc[:username],
      :password => acc[:password],
      :from_name => acc[:from_name],
      :from_email => acc[:from_email],
      :copy_customer => acc[:copy_customer],
      :copy_email => acc[:copy_email]
    }

    require 'net/http'
    require 'uri'
    require 'json'

    uri = URI.parse("http://dev.lockerstock.printexinc.com/")
    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new("/api/account")
    request.basic_auth "shopify", 'Ex1hDXNhJMH7bLTxtRqe'
    request.body = @account.to_query

    # Send the request
    response = http.request(request)

    res = JSON.parse(response.body)

    puts res.inspect
    puts res["message"]
    puts response.code
    @message = res["message"].gsub('\n', '');
    puts @message
    if response.code != "200"
      respond_to do |format|
        format.js{
          render :partial => "home/signup", :locals => {:message => @message }, :status => 200
        }
      end
    else
      @thisshop.printex_token = res["api_token"]
      @thisshop.username = acc["username"]
      @thisshop.password = acc["password"]
      @thisshop.save
      redirect_to :action => "index"
    end
  end

  def account_params
    params.require(:account).permit!
  end

  def refresh_products
    @products = []
    (1..pages).each do |page|
      @products += ShopifyAPI::Product.all(params: { page: page, limit: PER_PAGE })
    end

    @thisshop = Shop.find_by_shopify_domain current_shopify_domain

    @filteredProd = []
    @products.each do |product|
      vendor = product.vendor.downcase
      @filteredProd << product if vendor == "printex"
    end

    for product in @filteredProd
      save_product_in_db( product, @thisshop)
    end

    redirect_to :action => "index"
    return
  end

  def save_product_in_db( product, shop)
    p = Product.new
    p.title = product.title
    p.product_id = product.id
    p.shop = shop
    p.save
  end

  def settings
    # @thisshop = Shop.find_by_shopify_domain current_shopify_domain
    @thisshop = Shop.find_by_shopify_domain current_shopify_domain
    puts @thisshop.inspect
  end

  def save_settings
    # s = params.require(:shop).permit!
    # puts "sss 88* ** ** ** ** * ** "
    # puts s.inspect
    # @newtoken = s[:shop][:printex_token]
    # @thisshop.printex_token = @newtoken
    # @thisshop.save

    # redirect_to :action => "settings"
  end
  def save_token
    @thisshop = Shop.find_by_shopify_domain current_shopify_domain
    parameters = params.permit(:printex_token)
    @thisshop.printex_token = parameters[:printex_token]

    @show_notification = true if @thisshop.save

    redirect_to :settings
    return
  end

  private

  PER_PAGE = 200
  # calculates total number of pages required
  def pages
    count = ShopifyAPI::Product.count
    return 1 if count.zero?

    div, mod = count.divmod(PER_PAGE)
    if div.zero?
      1
    elsif mod > 0
      div + 1
    else
      div
    end
  end
  def settings_params
    # params.require(:shop).permit!
  end
end
