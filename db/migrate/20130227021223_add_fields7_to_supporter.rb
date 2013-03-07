class AddFields7ToSupporter < ActiveRecord::Migration
  def change
    add_column :supporters, :ssp_youth, :boolean
    add_column :supporters, :ssp_parent, :boolean
    add_column :supporters, :ssp_adult, :boolean
    add_column :supporters, :ssp_grandparent, :boolean
    add_column :supporters, :ssp_leader, :boolean
    add_column :supporters, :ssp_heard, :boolean
    add_column :supporters, :ssp_friends, :boolean
    add_column :supporters, :ssp_web, :boolean
    add_column :supporters, :ssp_other, :string
  end
end
