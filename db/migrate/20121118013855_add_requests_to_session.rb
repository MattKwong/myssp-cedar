class AddRequestsToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :requests, :integer
  end
end
