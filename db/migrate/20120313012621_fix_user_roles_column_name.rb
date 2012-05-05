class FixUserRolesColumnName < ActiveRecord::Migration
  def self.up
    rename_column :user_roles, :role_name, :name
  end

  def self.down
  end
end

