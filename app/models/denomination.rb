# == Schema Information
#
# Table name: denominations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Denomination < ActiveRecord::Base
  has_many :church_type
    attr_accessible :name

  validates :name, :presence => true, :uniqueness => true
end
