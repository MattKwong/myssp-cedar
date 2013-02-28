# == Schema Information
#
# Table name: adjustments
#
#  id          :integer          not null, primary key
#  group_id    :integer
#  updated_by  :integer
#  amount      :decimal(, )
#  reason_code :integer
#  note        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Adjustment < ActiveRecord::Base
  attr_accessible :id, :amount, :reason_code,
                  :note, :group_id, :updated_by

  belongs_to :scheduled_group
  belongs_to :adjustment_code, :foreign_key => :reason_code
  validates :amount, :reason_code, :presence => true
  validates_numericality_of :amount

end
