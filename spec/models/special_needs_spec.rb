require 'spec_helper'

# == Schema Information
#
# Table name: special_needs
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  list_priority :integer
#  created_at    :datetime
#  updated_at    :datetime
#

describe SpecialNeed do
  before (:each) do
    @attr = { :name => "special need", :list_priority => "list priority"  }
  end

  #validates :name, :presence => true, :uniqueness => true
  #validates :list_priority, :presence => true, :uniqueness => true

  it "should create an instance with valid attributes" do
    item = SpecialNeed.new(@attr)
    item.should be_valid
  end

  describe "name tests" do

    it "should require a name" do
      item = SpecialNeed.new(@attr.merge(:name => ""))
      item.should_not be_valid
    end

    it "name should be unique" do
      item1 = SpecialNeed.create!(@attr.merge(:name => 'Test'))
      item2 = SpecialNeed.new(@attr.merge(:name => 'Test'))
      item2.should_not be_valid
    end

  end

  describe "list_priority tests" do

    it "should require a list_priority" do
      item = SpecialNeed.new(@attr.merge(:list_priority => ""))
      item.should_not be_valid
    end

    it "list_priority should be unique" do
      item1 = SpecialNeed.create!(@attr.merge(:list_priority => 'Test'))
      item2 = SpecialNeed.new(@attr.merge(:list_priority => 'Test'))
      item2.should_not be_valid
    end

  end
  
end
