# == Schema Information
#
# Table name: checklist_items
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  due_date       :date
#  notes          :string(255)
#  seq_number     :integer
#  description    :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  active         :boolean
#  default_status :string(255)
#

class ChecklistItem < ActiveRecord::Base
  attr_accessible :name, :due_date, :notes, :seq_number, :description, :active, :default_status

  validates :name, :presence => true,
                    :length => { :within => 6..40},
                    :uniqueness => true
    validates_numericality_of :seq_number,  :allow_blank => false, :only_integer =>  true, :less_than => 100,
                              :greater_than_or_equal_to => 0
  validates :due_date, :default_status, :presence => true
end
