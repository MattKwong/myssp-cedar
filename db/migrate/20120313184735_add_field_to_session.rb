class AddFieldToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :program_id, :integer
  end

  def self.down
    remove_column :sessions, :program_id
  end
end
