class AddFields8ToSupporters < ActiveRecord::Migration
  def change
        add_column :supporters, :ssp_current_youth, :boolean
        add_column :supporters, :ssp_former_youth, :boolean
        remove_column :supporters, :ssp_youth
  end
end
