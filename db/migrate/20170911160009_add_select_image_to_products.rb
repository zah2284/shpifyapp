class AddSelectImageToProducts < ActiveRecord::Migration[5.1]
  def up
    add_column :products, :image, :integer, :null => true
  end
  def down
    remove_column :products, :image
  end
end
