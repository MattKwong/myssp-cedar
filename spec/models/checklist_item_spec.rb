require 'spec_helper'

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

describe ChecklistItem do
  before (:each) do
    @attr = { :name => "Checklist Item", :seq_number => 1, :due_date => Date.today, :default_status => "Default Status"}
  end

  #validates :name, :presence => true,
  #          :length => { :within => 6..40},
  #          :uniqueness => true
  #validates_numericality_of :seq_number,  :allow_blank => false, :only_integer =>  true, :less_than => 100,
  #                          :greater_than_or_equal_to => 0
  #validates :due_date, :default_status, :presence => true

  it "should create a new instance with valid attributes" do
    item = ChecklistItem.create!(@attr)
    item.should be_valid
  end

  describe "name tests" do
    it "name should not be blank" do
      no_name = ChecklistItem.new(@attr.merge(:name => ""))
      no_name.should_not be_valid
    end

    it "name should be unique" do
      item1 = ChecklistItem.create!(@attr)
      item2 = ChecklistItem.new(@attr)
      item2.should_not be_valid
    end

    it "name should be at least 6 characters" do
      expect { item = ChecklistItem.create!(@attr.merge(:name => "12345")) }.to raise_error
      #item.should_not be_valid
    end

    it "name should be <= 40 characters" do
      expect { item = ChecklistItem.create!(@attr.merge(:name => "0123456789 0123456789 0123456789 0123456789")) }.to raise_error
      #item.should_not be_valid
    end

  end

  describe "seq_number tests" do
    it "should not be blank" do
      item = ChecklistItem.new(@attr.merge(:seq_number => ""))
      item.should_not be_valid
    end

    it "should be an integer" do
      item = ChecklistItem.new(@attr.merge(:seq_number => "not an integer"))
      item.should_not be_valid
    end

    it "should be at >= 0" do
      item = ChecklistItem.new(@attr.merge(:seq_number => -1))
      item.should_not be_valid
    end

    it "should be at < 100" do
      item = ChecklistItem.new(@attr.merge(:seq_number => 1000))
      item.should_not be_valid
    end
  end

  it "should have a due date" do
    item = ChecklistItem.new(@attr.merge(:due_date => ""))
    item.should_not be_valid
  end

  it "should have a default_status" do
    item = ChecklistItem.new(@attr.merge(:default_status => ""))
    item.should_not be_valid
  end
end
