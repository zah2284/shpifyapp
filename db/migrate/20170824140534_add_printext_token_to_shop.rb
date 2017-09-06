class AddPrintextTokenToShop < ActiveRecord::Migration[5.1]
  def up
    add_column :shops, :printex_token, :string
  end
  def down
    remove_column :shops, :printex_token
  end
end
