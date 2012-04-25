class CreateSpecialNeeds < ActiveRecord::Migration
  def self.up
    create_table :special_needs do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :special_needs
  end
end
