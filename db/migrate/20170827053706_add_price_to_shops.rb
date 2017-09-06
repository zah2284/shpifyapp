class AddPriceToShops < ActiveRecord::Migration[5.1]
  def up
    add_column :shops, :currency, :string
  end

  def down
    remove_column :shops, :currency
  end
end
