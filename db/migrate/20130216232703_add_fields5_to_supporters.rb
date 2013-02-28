class AddFields5ToSupporters < ActiveRecord::Migration
  def change
    add_column :supporters, :fund_exper, :boolean
    add_column :supporters, :fund_exper_comments, :string
    add_column :supporters, :fund_connect, :boolean
    add_column :supporters, :fund_connect_comments, :string
    add_column :supporters, :fund_in_kind, :boolean
    add_column :supporters, :fund_in_kind_comments, :string
    add_column :supporters, :desire_board, :boolean
    add_column :supporters, :desire_training, :boolean
    add_column :supporters, :desire_outreach, :boolean
    add_column :supporters, :desire_work_projects, :boolean
    add_column :supporters, :desire_web, :boolean
    add_column :supporters, :desire_other, :boolean
    add_column :supporters, :desire_other_comments, :string
  end
end
