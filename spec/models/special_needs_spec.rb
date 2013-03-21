require 'spec_helper'

describe SpecialNeed do
  before (:each) do
    @attr = { :name => "Name", :list_priority => 2}
  end

  #class SpecialNeed < ActiveRecord::Base
  #  attr_accessible :name, :list_priority
  #
  #  validates :name, :presence => true, :uniqueness => true
  #  validates :list_priority, :presence => true, :uniqueness => true
  #
  #end

  it "should create a new instance with valid attributes" do
    item = SpecialNeed.new(@attr)
    item.should be_valid
  end

  describe "name tests" do

    it "should have a name" do
      item = SpecialNeed.new(@attr.merge(:name => ""))
      item.should_not be_valid
    end

    it "should be unique" do
      item1 = SpecialNeed.create!(@attr.merge(:name => "Same Name"))
      item2 = SpecialNeed.new(@attr.merge(:name => "Same Name"))
      item2.should_not be_valid
    end

  end

  describe "list priority tests" do

    it "should have a list priority" do
      item = SpecialNeed.new(@attr.merge(:list_priority => ""))
      item.should_not be_valid
    end

    it "should be unique" do
      item1 = SpecialNeed.create!(@attr.merge(:list_priority => 1))
      item2 = SpecialNeed.new(@attr.merge(:list_priority => 1))
      item2.should_not be_valid
    end

  end

end
