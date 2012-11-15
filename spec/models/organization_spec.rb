# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Organization do
  before (:each) do
    @attr = { :name => "Generic Organization"}
  end

  #validates :name, :presence => true, :uniqueness => true

  it "should create a new instance with valid attributes" do
    Organization.create!(@attr)
  end

  describe "name tests" do

    it "name should not be blank" do
      no_name = Organization.new(@attr.merge(:name => ""))
      no_name.should_not be_valid
    end

    it "name should be unique" do
      item1 = Organization.create!(@attr)
      item2 = Organization.new(@attr)
      item2.should_not be_valid
    end

  end

  it "should have many church_types" do
    should have_many(:church_type)
  end

end
