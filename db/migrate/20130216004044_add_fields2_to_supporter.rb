class AddFields2ToSupporter < ActiveRecord::Migration
  def change
    add_column :supporters, :skill_comp_prog, :boolean
    add_column :supporters, :skill_comp_prog_comments, :string
  end
end
