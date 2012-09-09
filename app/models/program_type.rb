# == Schema Information
#
# Table name: program_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  position    :integer
#

class ProgramType < ActiveRecord::Base
  attr_accessible :name, :description

  validates :name, :description, :presence => true
  validates :name, :uniqueness => true

end
