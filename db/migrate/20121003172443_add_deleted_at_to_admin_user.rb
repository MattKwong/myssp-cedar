class AddDeletedAtToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :deleted_at, :datetime
  end
end
