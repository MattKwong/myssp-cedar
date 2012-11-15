# == Schema Information
#
# Table name: session_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime

require 'spec_helper'

describe SessionType do
  before (:each) do
    @attr = { :name => "A Session Type", :description => "ST Description"}
  end

  #validates :name, :description, :presence => true
  #validates :name, :uniqueness => true

  it "should create a new instance with valid attributes" do
    item = SessionType.create!(@attr)
    item.should be_valid
  end

  describe "name tests" do

    it "name should not be blank" do
      item = SessionType.new(@attr.merge(:name => ''))
      item.should_not be_valid
    end

    it "name should be unique" do
      item1 = SessionType.create!(@attr)
      item2 = SessionType.new(@attr)
      item2.should_not be_valid
    end

    describe "Junior High Session Name" do

      it "FUNCTION: Test if session type is junior high" do
        item = SessionType.new(@attr.merge(:name => 'Junior High'))
        item.junior_high?.should be_true
      end

      it "FUNCTION: if session is 'Junior High' then limit should be 20" do
        item = SessionType.new(@attr.merge(:name => 'Junior High'))
        item.limit.should == 20
      end

      it "FUNCTION: Test if session type is senior high" do
        item = SessionType.new(@attr.merge(:name => 'Junior High'))
        item.senior_high?.should be_false
      end

      it "FUNCTION: if session is not 'Junior High' then limit should be 30" do
        item = SessionType.new(@attr.merge(:name => 'Not Junior High'))
        item.limit.should == 30
      end

    end

  end

  describe "description tests" do

    it "description should not be blank" do
      item = SessionType.new(@attr.merge(:description => ''))
      item.should_not be_valid
    end

  end

end