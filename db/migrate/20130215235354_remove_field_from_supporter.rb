class RemoveFieldFromSupporter < ActiveRecord::Migration
  def up
    remove_column :supporters, :phone_type
    add_column :supporters, :phone_type, :string
  end

  def down
    remove_column :supporters, :phone_type
    add_column :supporters, :phone_type, :text
  end
end
