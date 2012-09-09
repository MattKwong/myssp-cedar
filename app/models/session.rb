# == Schema Information
#
# Table name: sessions
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  site_id             :integer
#  period_id           :integer
#  session_type_id     :integer
#  created_at          :datetime
#  updated_at          :datetime
#  payment_schedule_id :integer
#  program_id          :integer
#

class Session < ActiveRecord::Base

  belongs_to :site
  belongs_to :period
  belongs_to :session_type
  belongs_to :payment_schedule
  has_many :scheduled_groups
  accepts_nested_attributes_for :scheduled_groups

  attr_accessible :name, :period_id, :site_id, :payment_schedule_id, :session_type_id
end
