class CreateLoginRequestTable < ActiveRecord::Migration
  def change
    create_table :login_requests do |t|
      t.boolean :approved
      t.boolean :user_created
      t.string :church_city
      t.string :church_name
      t.string :church_city
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :phone_number_type
      t.string :how_heard
      t.timestamps
    end
  end
end
