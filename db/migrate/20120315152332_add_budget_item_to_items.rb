class AddBudgetItemToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :budget_item_type_id, :integer
  end

  def self.down
    remove_column :items, :budget_item_type_id
  end
end
