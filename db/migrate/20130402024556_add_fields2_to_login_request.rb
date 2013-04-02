class AddFields2ToLoginRequest < ActiveRecord::Migration
  def change
    add_column :login_requests, :church_address1, :string
    add_column :login_requests, :church_address2, :string
    add_column :login_requests, :church_state, :string
    add_column :login_requests, :church_zip, :string
    add_column :login_requests, :church_office_phone, :string
    add_column :login_requests, :church_office_fax, :string
    add_column :login_requests, :address1, :string
    add_column :login_requests, :address2, :string
    add_column :login_requests, :city, :string
    add_column :login_requests, :zip, :string
    add_column :login_requests, :alt_phone_number, :string
    add_column :login_requests, :alt_phone_number_type, :string
    add_column :login_requests, :state, :string
  end
end
