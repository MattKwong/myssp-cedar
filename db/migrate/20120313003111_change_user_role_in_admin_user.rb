class ChangeUserRoleInAdminUser < ActiveRecord::Migration
  def self.up
    remove_column :admin_users, :username
    add_column :admin_users, :username, :integer
  end

  def self.down
    remove_column :admin_users, :username
    add_column :admin_users, :username, :string
  end
end
