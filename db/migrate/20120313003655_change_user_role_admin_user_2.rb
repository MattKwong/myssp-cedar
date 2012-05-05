class ChangeUserRoleAdminUser2 < ActiveRecord::Migration
  def self.up
    remove_column :admin_users, :user_role
    add_column :admin_users, :user_role, :integer
  end

  def self.down
    remove_column :admin_users, :user_role
    add_column :admin_users, :user_role, :string
  end
end
