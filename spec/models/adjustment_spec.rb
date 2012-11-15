# == Schema Information
#
# Table name: adjustments
#
#  id          :integer          not null, primary key
#  group_id    :integer
#  updated_by  :integer
#  amount      :decimal(, )
#  reason_code :integer
#  note        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe Adjustment do
  before (:each) do
    @attr = { :amount => "1", :reason_code => "Reason Code" }
  end

  #validates :amount, :reason_code, :presence => true
  #validates_numericality_of :amount

  it "should create an instance with valid attributes" do
    item = Adjustment.new(@attr)
    item.should be_valid
  end

  describe "amount tests" do

    it "should require amount" do
      item = Adjustment.new(@attr.merge(:amount => ""))
      item.should_not be_valid
    end

    it "should be a number" do
      item = Adjustment.new(@attr.merge(:amount => "x"))
      item.should_not be_valid
    end

  end

  describe "reason code tests" do

    it "should require reason_code" do
      item = Adjustment.new(@attr.merge(:reason_code => ""))
      item.should_not be_valid
    end

  end

  #describe "hierarchy test" do
  #  it "should belong to a scheduled group" do
  #    item = Adjustment.new(@attr)
  #    scheduled_group = ScheduledGroup.new( :adjustment => item )
  #    scheduled_group.should be valid
  #  end
  #end

end

