class AddShopIdToProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :shop_id , :integer
    add_column :products, :product_id, :string
  end
end
