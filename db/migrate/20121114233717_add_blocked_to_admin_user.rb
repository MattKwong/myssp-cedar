class AddBlockedToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :blocked, :boolean
  end
end
