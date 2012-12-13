class CreateSupporters < ActiveRecord::Migration
  def change
    create_table :supporters do |t|
      t.string :first_name
      t.string :last_name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :affiliation
      t.string :profession
      t.string :employer
      t.string :gender

      t.timestamps
    end
  end
end
