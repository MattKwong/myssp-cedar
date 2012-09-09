# == Schema Information
#
# Table name: rosters
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  group_type :integer
#  created_at :datetime
#  updated_at :datetime
#

class Roster < ActiveRecord::Base
  attr_accessible :id, :group_id, :group_type
    belongs_to :scheduled_group, :foreign_key => :group_id
    has_many :roster_items

    validates :group_id, :group_type, :presence => true

  def name
<<<<<<< HEAD
    unless group_id.nil?
      scheduled_group.name
=======
    unless self.scheduled_group.nil?
      self.scheduled_group.name
    else
      "None"
>>>>>>> upstream/master
    end
  end
end
