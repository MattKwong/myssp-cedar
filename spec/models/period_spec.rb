# == Schema Information
#
# Table name: periods
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  start_date      :datetime
#  end_date        :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  active          :boolean
#  summer_domestic :boolean
#

require 'spec_helper'

describe Period do

  before (:each) do
    @attr = { :name => "Period", :start_date => Date.today+1, :end_date => Date.today+3}
  end

  #validates :name, :start_date, :end_date, :presence => true
  #validate :start_date_before_end_date
  #validate :start_date_not_in_past

  it "should create a new instance with valid attributes" do
    item = Period.create!(@attr)
    item.should be_valid
  end

  it "name should not be blank" do
    no_name = Period.new(@attr.merge(:name => ""))
    no_name.should_not be_valid
  end

  it "start date should not be blank" do
    item = Period.new(@attr.merge(:start_date => nil))
    item.should_not be_valid
  end

  it "end date should not be blank" do
    item = Period.new(@attr.merge(:end_date => ''))
    item.should_not be_valid
  end

  it "start date cannot be in the past" do
      item = Period.new(@attr.merge(:start_date => Date.today-4))
      item.should_not be_valid
  end

  it "start date can be the same as end date" do
      item = Period.new(@attr.merge(:start_date => Date.today, :end_date => Date.today))
      item.should be_valid
  end

  it "start date cannot be after end date" do
    item = Period.new(@attr.merge(:start_date => Date.today+4, :end_date => Date.today+2))
    item.should_not be_valid
  end

end
