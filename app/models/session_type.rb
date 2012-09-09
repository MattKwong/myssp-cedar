# == Schema Information
#
# Table name: session_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class SessionType < ActiveRecord::Base

  attr_accessible :name, :description

  validates :name, :description, :presence => true
  validates :name, :uniqueness => true

end
