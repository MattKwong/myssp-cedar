class AddField6ToSupporters < ActiveRecord::Migration
  def change
    add_column :supporters, :desire_publicity, :boolean
  end
end
