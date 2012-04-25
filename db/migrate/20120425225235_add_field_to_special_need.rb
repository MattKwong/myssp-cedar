class AddFieldToSpecialNeed < ActiveRecord::Migration
  def self.up
    add_column :special_needs, :list_priority, :integer
  end

  def self.down
    remove_column :special_needs, :list_priority
  end
end
