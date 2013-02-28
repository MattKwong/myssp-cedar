class AddFields7toSupporters < ActiveRecord::Migration
  def up
    add_column :supporters, :final_comments, :text
  end

  def down
  end
end
