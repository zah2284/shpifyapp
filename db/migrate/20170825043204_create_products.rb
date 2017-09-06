class CreateProducts < ActiveRecord::Migration[5.1]
  def up
    create_table :products do |t|
      t.string :title, :limit => 700, :null => false
      t.text :description
      t.string :vendor
      t.string :type
      t.timestamps
    end
    add_attachment :products, :image
  end

  def down
    drop_table :products
  end
end
