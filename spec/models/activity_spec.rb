# == Schema Information
#
# Table name: activities
#
#  id               :integer          not null, primary key
#  activity_type    :string(255)
#  activity_details :string(255)
#  user_id          :integer
#  user_name        :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  user_role        :string(255)
#  activity_date    :datetime
#

require 'spec_helper'

describe Activity do
  before (:each) do
    @attr = { :activity_date => DateTime.now, :activity_details => "Posting of new test transaction", :activity_type => "Adjustment", :user_id => 1,
              :user_name => "Current User" }
  end

  #validates  :activity_date, :activity_details, :activity_type, :user_id, :user_name,  :presence => true
  #validates_numericality_of :user_id, :only_integer => true, :greater_than => 0
  #validates_datetime :activity_date

  describe "activity date tests" do

    it "should require activity_date" do
      item = Activity.new(@attr.merge(:activity_date => ""))
      item.should_not be_valid
    end

  end

  describe "activity details tests" do

    it "should require activity_details" do
      item = Activity.new(@attr.merge(:activity_details => ""))
      item.should_not be_valid
    end

  end

  describe "activity type tests" do

    it "should require activity_type" do
      item = Activity.new(@attr.merge(:activity_type => ""))
      item.should_not be_valid
    end

  end

  describe "user id tests" do

    it "should require user_id" do
      item = Activity.new(@attr.merge(:user_id=> ""))
      item.should_not be_valid
    end

    it "should be an integer (Test 1)" do
      item = Activity.new(@attr.merge(:user_id=> "x"))
      item.should_not be_valid
    end

    it "should be an integer (Test 2)" do
      item = Activity.new(@attr.merge(:user_id=> "4.4"))
      item.should_not be_valid
    end

    it "should be greater than 0" do
      item = Activity.new(@attr.merge(:user_id=> "0"))
      item.should_not be_valid
    end

    it "should not be less than zero" do
      item = Activity.new(@attr.merge(:user_id=> "-4"))
      item.should_not be_valid
    end

  end

  describe "user name tests" do

    it "should require user_name" do
      item = Activity.new(@attr.merge(:user_name=> ""))
      item.should_not be_valid
    end

  end


  describe "activity date tests" do

    it "should require an activity_date" do
      item = Activity.new(@attr.merge(:activity_date=> ""))
      item.should_not be_valid
    end

    it "should require a valid date" do
      item = Activity.new(@attr.merge(:activity_date=> "xyz"))
      item.should_not be_valid
    end

  end

end

