class AddToItemCategory < ActiveRecord::Migration
  def self.up
    add_column :item_categories, :position, :integer
  end

  def self.down
    remove_column :item_categories, :position
  end
end
