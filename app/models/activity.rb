# == Schema Information
#
# Table name: activities
#
#  id               :integer          not null, primary key
#  activity_type    :string(255)
#  activity_details :string(255)
#  user_id          :integer
#  user_name        :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  user_role        :string(255)
#  activity_date    :datetime
#

class Activity < ActiveRecord::Base
  attr_accessible :id, :activity_date, :activity_details, :activity_type, :user_id, :user_name, :user_role

  validates  :activity_date, :activity_details, :activity_type, :user_id, :user_name,  :presence => true
  validates_numericality_of :user_id, :only_integer => true, :greater_than => 0,  :if => :user_name != 'Guest'
  validates_datetime :activity_date

end
