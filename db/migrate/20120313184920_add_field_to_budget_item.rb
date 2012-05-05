class AddFieldToBudgetItem < ActiveRecord::Migration
  def self.up
    add_column :budget_items, :program_id, :integer
  end

  def self.down
    remove_column :budget_items, :program_id
  end
end
