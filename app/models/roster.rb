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
    unless self.scheduled_group.nil?
      self.scheduled_group.name
    else
      "None"
    end
  end

  def roster_status
    items = RosterItem.find_all_by_roster_id(id)
    if items.nil? || items.count == 0
      return 'Not started'

    else
      if items.count < scheduled_group.current_total
        return "Started"
      else if items.count == scheduled_group.current_total
             return "Completed"
           else
             return "Needs attention"
           end
      end
    end

  end

  def left_to_enter
    items = RosterItem.find_all_by_roster_id(id)
    if items.nil? || items.count == 0
      return scheduled_group.current_total
    else
      return scheduled_group.current_total - items.count
    end
  end

end
