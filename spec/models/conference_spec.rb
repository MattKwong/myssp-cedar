# == Schema Information
#
# Table name: conferences
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Conference do
  before (:each) do
    @attr = { :name => "Generic Conference"}
  end

  it "should create a new instance with valid attributes" do
    item = Conference.create!(@attr)
    item.should be_valid
  end

  describe "name tests" do
    it "name should not be blank" do
      no_name = Conference.new(@attr.merge(:name => ""))
      no_name.should_not be_valid
    end

    it "name should be unique" do
      item1 = Conference.create!(@attr)
      item2 = Conference.new(@attr)
      item2.should_not be_valid
    end
  end
end
