# == Schema Information
#
# Table name: scheduled_histories
#
#  id                 :integer          not null, primary key
#  registration_id    :integer
#  history_date       :date
#  action             :string(255)
#  comments           :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  scheduled_group_id :integer
#

class ScheduledHistory < ActiveRecord::Base
  belongs_to :scheduled_group
end
