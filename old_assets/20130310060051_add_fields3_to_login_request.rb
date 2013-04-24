class AddFields3ToLoginRequest < ActiveRecord::Migration
  def change
    add_column :login_requests, :state, :string
  end
end
