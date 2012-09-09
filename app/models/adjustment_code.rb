# == Schema Information
#
# Table name: adjustment_codes
#
#  id         :integer          not null, primary key
#  short_name :string(255)
#  long_name  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class AdjustmentCode < ActiveRecord::Base
end
