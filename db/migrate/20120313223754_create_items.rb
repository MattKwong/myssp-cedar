class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :program_id
      t.integer :item_type_id
      t.integer :program_id
      t.string :name
      t.string :description
      t.string :notes
      t.string :base_unit
      t.boolean :default_taxed
      t.integer :item_category_id

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end

