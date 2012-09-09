<<<<<<< HEAD
# == Schema Information
#
# Table name: special_needs
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  list_priority :integer
#  created_at    :datetime
#  updated_at    :datetime
#
=======
>>>>>>> upstream/master

class SpecialNeed < ActiveRecord::Base
  attr_accessible :name, :list_priority

  validates :name, :presence => true, :uniqueness => true
  validates :list_priority, :presence => true, :uniqueness => true

end
