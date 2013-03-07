class Supporter10AddFields < ActiveRecord::Migration
  def change
    add_column :supporters, :desire_plan_events, :boolean
    add_column :supporters, :skill_plan_events, :boolean
    change_column :supporters, :desire_other_comments, :text
  end
end
