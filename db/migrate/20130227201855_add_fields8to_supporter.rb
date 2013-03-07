class AddFields8toSupporter < ActiveRecord::Migration
  def change
    add_column :supporters, :newsletter_subscribe, :boolean
    add_column :supporters, :email, :string
  end
end
