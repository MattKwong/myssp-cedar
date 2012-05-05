class CreateItemPurchases < ActiveRecord::Migration
  def self.up
    create_table :item_purchases do |t|
      t.integer :item_id
      t.integer :purchase_id
      t.decimal :quantity
      t.string :size
      t.string :uom
      t.decimal :price
      t.boolean :taxable
      t.decimal :total_base_units

      t.timestamps
    end
  end

  def self.down
    drop_table :item_purchases
  end
end
