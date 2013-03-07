class AddFieldsToSupporter2 < ActiveRecord::Migration
  def change
    add_column :supporters, :employer_match, :boolean
    add_column :supporters, :employer_foundation, :boolean
    add_column :supporters, :employer_comments, :string
    add_column :supporters, :service_club, :string
    add_column :supporters, :other_community, :boolean
    add_column :supporters, :other_community_text, :string
  end
end
