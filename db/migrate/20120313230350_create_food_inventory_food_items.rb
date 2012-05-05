class CreateFoodInventoryFoodItems < ActiveRecord::Migration
  def self.up
    create_table :food_inventory_food_items do |t|
      t.integer :food_inventory_id
      t.integer :item_id
      t.string :quantity
      t.decimal :in_base_units
      t.decimal :in_inventory
      t.decimal :average_cost

      t.timestamps
    end
  end

  def self.down
    drop_table :food_inventory_food_items
  end
end
