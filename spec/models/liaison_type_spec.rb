# == Schema Information
#
# Table name: liaison_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe LiaisonType do
  before (:each) do
    @attr = { :name => "Generic Type", :description => "Liaison Type Description"}
  end

  #validates :name, :presence => true, :uniqueness => true
  #validates :description, :presence => true

  it "should create a new instance with valid attributes" do
    item = LiaisonType.create!(@attr)
    item.should be_valid
  end

  describe "name tests" do

    it "name should not be blank" do
      no_name = LiaisonType.new(@attr.merge(:name => ""))
      no_name.should_not be_valid
    end

    it "name should be unique" do
      church1 = LiaisonType.create!(@attr.merge(:name => "John Doe"))
      church2 = LiaisonType.new(@attr.merge(:name => "John Doe"))
      church2.should_not be_valid
    end

  end

  describe "description tests" do

    it "description should not be blank" do
      church2 = LiaisonType.new(@attr.merge(:description => ""))
      church2.should_not be_valid
    end

  end

end
