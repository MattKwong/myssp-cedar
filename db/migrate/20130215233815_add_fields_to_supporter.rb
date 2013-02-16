class AddFieldsToSupporter < ActiveRecord::Migration
  def change
    add_column :supporters, :phone, :string
    add_column :supporters, :phone_type, :text
    add_column :supporters, :church_name, :string
    add_column :supporters, :church_city, :string
    add_column :supporters, :church_denom, :string
    add_column :supporters, :church_role, :string
  end
end
