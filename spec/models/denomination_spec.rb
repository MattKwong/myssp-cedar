# == Schema Information
#
# Table name: denominations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Denomination do
  before (:each) do
    @attr = { :name => "Generic Denomination"}
  end

  it "should create a new instance with valid attributes" do
    item = Denomination.create!(@attr)
    item.should be_valid
  end

  describe "name tests" do
    it "name should not be blank" do
      no_name = Denomination.new(@attr.merge(:name => ""))
      no_name.should_not be_valid
    end

    it "name should be unique" do
      church1 = Denomination.create!(@attr)
      church2 = Denomination.new(@attr)
      church2.should_not be_valid
    end
  end

end
