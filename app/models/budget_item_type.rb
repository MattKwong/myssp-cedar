# == Schema Information
#
# Table name: budget_item_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  seq_number  :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class BudgetItemType < ActiveRecord::Base
  has_many :budget_items
  has_many :item
  attr_accessible :description, :name, :seq_number
  default_scope :order => 'seq_number'
  validates :name, :presence => true, :uniqueness => true
  validates :description, :seq_number, :presence => true
  validates_numericality_of :seq_number, :greater_than_or_equal_to => 0, :integer => true

  def food?
    self.name == "Food"
  end

  def materials?
    self.name == "Materials"
  end
end
