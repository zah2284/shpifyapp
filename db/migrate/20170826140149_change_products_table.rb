class ChangeProductsTable < ActiveRecord::Migration[5.1]
  def change
    remove_column :products, :description
    remove_column :products, :vendor
    remove_column :products, :type
    remove_attachment :products, :image
  end
end
