class ChangeComments < ActiveRecord::Migration
  def change
    remove_column :scheduled_groups, :comments
    add_column :scheduled_groups, :comments, :text
  end
end
