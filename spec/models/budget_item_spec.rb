# == Schema Information
#
# Table name: budget_items
#
#  id                  :integer          not null, primary key
#  site_id             :integer
#  budget_item_type_id :integer
#  amount              :decimal(, )
#  created_at          :datetime
#  updated_at          :datetime
#  program_id          :integer
#

require 'spec_helper'

describe BudgetItem do
  before (:each) do
    @attr = { :amount => 1.5, :budget_item_type_id => 123, :program_id => 123}
    #@attr = { :id => 123, :site_id => 123, :budget_item_type_id => 123, :amount => 1.5, :created_at => Date.today-1,
    #:updated_at => Date.today, :program_id => 123}
  end

  #belongs_to :budget_item_type
  #belongs_to :program
  #attr_accessible :amount, :budget_item_type_id, :program_id

  #validates :budget_item_type_id, :amount, :presence => true
  #validates_numericality_of :amount, :greater_than_or_equal_to => 0, :decimal => true

  #it {should belong_to :budget_item_type}
  #it {should belong_to :program}

  pending "add some examples to (or delete) #{__FILE__}"

  pending "should create a new instance with valid attributes" do
    item = BudgetItem.create!(@attr)
    item.should be_valid
  end

end
