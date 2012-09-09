# == Schema Information
#
# Table name: group_checklist_statuses
#
#  id                :integer          not null, primary key
#  status            :string(255)
#  notes             :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  checklist_item_id :integer
#  group_id          :integer
#

class GroupChecklistStatus < ActiveRecord::Base
    attr_accessible :checklist_item_id, :group_id, :status, :notes

  validates :checklist_item_id, :group_id, :status, :presence => true
end
