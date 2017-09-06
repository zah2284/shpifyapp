class AddAttributesToShop < ActiveRecord::Migration[5.1]
  def up
    add_column :shops, :username, :string, :null => true
    add_column :shops, :password, :string, :null => true
  end

  def down
    remove_column :shops, :username
    remove_column :shops, :password
  end
end
