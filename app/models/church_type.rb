# == Schema Information
#
# Table name: church_types
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  updated_at      :datetime
#  name            :string(255)
#  denomination_id :integer
#  conference_id   :integer
#  organization_id :integer
#

class ChurchType < ActiveRecord::Base
  belongs_to :conference
  belongs_to :denomination
  belongs_to :organization

  attr_accessible :name

  validates :name, :presence => true, :uniqueness => true
end
