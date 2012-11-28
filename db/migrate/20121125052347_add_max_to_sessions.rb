class AddMaxToSessions < ActiveRecord::Migration
  def change
    add_column :sessions, :schedule_max, :integer
  end
end
