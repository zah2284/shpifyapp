class ChangeImageTypeToString < ActiveRecord::Migration[5.1]
  def up
    remove_column :products, :image
    add_column :products, :image, :string, :null => true
  end

  def down
    remove_column :products, :image
    add_column :products, :image, :integer, :null => true
  end
end
