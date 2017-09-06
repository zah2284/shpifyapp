class ProductController < ShopifyApp::AuthenticatedController
  def add
    @thisshop = ShopifyAPI::Shop.current
  end

  def save_product
    d = product_params
    product_images = []
    if d["product_image"] != nil
      d["product_image"].each do |key,image|
        im = {}
        im[:src] = image
        product_images << im if image != ""
      end
    end
    # doing shopify api call to create a product
    product = ShopifyAPI::Product.new
    product.title = d["product_title"]
    product.vendor = d["product_vendor"]
    product.product_type = d["product_type"]
    product.body_html = d["product_description"]
    product.images = product_images
    product.options = []
    product.variants = []

    if d[:product_variant] != nil
      # product options
      options_count = 0;
      d["product_options"].each do |key,option|
        if option != ""
          product.options << {:name => option}
          options_count = options_count + 1
        end
      end
      puts product.options.inspect

      # add product variants
      d[:product_variant].each do |key, variant|
        thisvariant = {}
        # thisvariant[:title] = "#{variant[:option_1]} #{variant[:option_2]} #{variant[:option_3]}"
        thisvariant[:option1] = variant[:option_1] if variant[:option_1] != nil
        thisvariant[:option2] = variant[:option_2] if variant[:option_2] != nil
        thisvariant[:option3] = variant[:option_3] if variant[:option_3] != nil
        thisvariant[:price] = variant[:price]
        thisvariant[:compare_at_price] = variant[:compare_at_price]

        product.variants << thisvariant
      end
    end

    product.save

    # if no product variant then default variant
    if d[:product_variant] == nil
      default_variant = product.variants.first
      default_variant.price = d[:product_price]
      default_variant.compare_at_price = d[:product_compare_price]
    end

    # adding product for printex
    product.add_metafield(ShopifyAPI::Metafield.new({
       :description => 'Printex Product',
       :namespace => 'printex',
       :key => 'is_printex',
       :value => 1,
       :value_type => 'integer'
    }));

    product.save

    # adding product to database
    @thisshop = Shop.find_by_shopify_domain current_shopify_domain
    p = Product.new
    p.title = product.title
    p.product_id = product.id
    p.shop = @thisshop
    p.save

    flash[:notice] = "Product added successfully"
    redirect_to :controller => "home", :action => "index"
    return
  end

  def remove
    respond_to do |format|
      format.js {
        p = params.permit(:id)
        @classid = p[:id]
        shop = Shop.find_by_shopify_domain current_shopify_domain
        product = shop.products.find(p[:id])
        sproduct = ShopifyAPI::Product.delete(product.product_id)
        product.destroy
      }
     end
  end

  def product_params
    params.permit(
      :product_title,
      :product_description,
      :product_vendor,
      :product_type,
      :product_price,
      :product_compare_price,
      :product_image => {},
      :product_options => {},
      :product_variant => {}
    )
  end
end
