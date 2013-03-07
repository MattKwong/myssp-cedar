class AddFields11ToSupporters < ActiveRecord::Migration
  def change
      change_column :supporters, :employer_comments, :text
      change_column :supporters, :final_comments, :text
      change_column :supporters, :fund_connect_comments, :text
      change_column :supporters, :fund_exper_comments, :text
      change_column :supporters, :fund_in_kind_comments, :text
      change_column :supporters, :other_community_text, :text
      change_column :supporters, :skill_comp_prog_comments, :text
      change_column :supporters, :skill_other_comments, :text
      change_column :supporters, :ssp_other, :text
      change_column :supporters, :profession, :text
      change_column :supporters, :employer, :text
  end
end
