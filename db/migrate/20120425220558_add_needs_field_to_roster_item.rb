class AddNeedsFieldToRosterItem < ActiveRecord::Migration
  def self.up
    add_column :roster_items, :special_need_id, :integer
  end

  def self.down
    remove_column :roster_items, :special_need_id
  end
end
