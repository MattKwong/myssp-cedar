class AddFieldToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :waitlist_flag, :boolean
  end
end
