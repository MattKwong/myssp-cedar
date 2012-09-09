# == Schema Information
#
# Table name: liaison_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class LiaisonType < ActiveRecord::Base

  attr_accessible :name, :description

  validates :name, :presence => true, :uniqueness => true
  validates :description, :presence => true

end
