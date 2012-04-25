class AddNeedsFieldToRosterItem2 < ActiveRecord::Migration
  def self.up
    remove_column :roster_items, :special_need_id
    add_column :roster_items, :special_need, :string
  end

  def self.down
    remove_column :roster_items, :special_need
    add_column :roster_items, :special_need_id, :integer
  end
end
