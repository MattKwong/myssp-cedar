# == Schema Information
#
# Table name: rosters
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  group_type :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Roster do
  before (:each) do
    @attr = { :id => 1, :group_id => 2, :group_type => 3}
  end

  #attr_accessible :id, :group_id, :group_type
  #belongs_to :scheduled_group, :foreign_key => :group_id
  #has_many :roster_items

  #validates :group_id, :group_type, :presence => true

  it "should create a new instance with valid attributes" do
    item = Roster.create!(@attr)
    item.should be_valid
  end

  it "should have a group_id" do
    item = Roster.new(@attr.merge(:group_id => ""))
    item.should_not be_valid
  end

  it "should have a group_type" do
    item = Roster.new(@attr.merge(:group_type => ""))
    item.should_not be_valid
  end

  describe "name tests" do
    pending "should be assigned the same name as the scheduled group it is a part of" do
      item = Roster.create!(@attr)
      #item.name.should == "None"
    end

    it "should be assigned the name 'None' if the scheduled group has no name" do
      item = Roster.create!(@attr)
      item.name.should == "None"
    end
  end

  pending "not sure how to test remaining functions"

end
