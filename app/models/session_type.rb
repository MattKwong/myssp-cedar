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

  scope :senior_high, where(:name => 'Summer Senior High')
  scope :junior_high, where(:name => 'Summer Junior High')

  def junior_high?
    name == "Summer Junior High" ? true : false
  end
  def senior_high?
    name == "Summer Junior High" ? true : false
  end
  def limit
    self.junior_high? ? 20 : 30
  end

  def schedule_largest_first
    #Finds all of the session for this session type.
    #Sorts them by the number of first choice requests
    sessions = Session.active.find_all_by_session_type_id(id)
    sessions.sort!{ |a, b| b.registered_total <=> a.registered_total}
    sessions.each do |s|
      s.schedule_requests(65, 68)
    end
  end
end
