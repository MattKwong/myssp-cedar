class AddFields4ToSupporters < ActiveRecord::Migration
  def change
    add_column :supporters, :skill_food_prep, :boolean
  end
end
