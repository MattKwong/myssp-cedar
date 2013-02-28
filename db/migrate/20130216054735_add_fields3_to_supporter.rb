class AddFields3ToSupporter < ActiveRecord::Migration
  def change
    add_column :supporters, :skill_architecture, :boolean
    add_column :supporters, :skill_auto_repair, :boolean
    add_column :supporters, :skill_board, :boolean
    add_column :supporters, :skill_carpentry, :boolean
    add_column :supporters, :skill_const, :boolean
    add_column :supporters, :skill_electrical, :boolean
    add_column :supporters, :skill_plumbing, :boolean
    add_column :supporters, :skill_press, :boolean
    add_column :supporters, :skill_safety, :boolean
    add_column :supporters, :skill_sewing, :boolean
    add_column :supporters, :skill_tool_repair, :boolean
    add_column :supporters, :skill_video, :boolean
    add_column :supporters, :skill_web, :boolean
    add_column :supporters, :skill_other, :boolean
    add_column :supporters, :skill_other_comments, :string
  end
end
