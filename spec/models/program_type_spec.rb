# == Schema Information
#
# Table name: program_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  position    :integer
#

require 'spec_helper'

describe ProgramType do
  before (:each) do
    @attr = { :name => "Program Type", :description => "PT Description", :position => 10}
  end

  #validates :name, :description, :position, :presence => true
  #validates :name, :uniqueness => true

  it "should create a new instance with valid attributes" do
    item = ProgramType.create!(@attr)
    item.should be_valid
  end

  describe "name tests" do

    it "should require a name" do
      item = ProgramType.new(@attr.merge(:name => ''))
      item.should_not be_valid
    end

    it "name should be unique" do
      item1 = ProgramType.create!(@attr.merge(:name => 'Test'))
      item2 = ProgramType.new(@attr.merge(:name => 'Test'))
      item2.should_not be_valid
    end

  end

  describe "description tests" do

    it "should require a description" do
      item = ProgramType.new(@attr.merge(:description => ''))
      item.should_not be_valid
    end

  end

  describe "position tests" do

    it "should require a position" do
      item = ProgramType.new(@attr.merge(:position => ''))
      item.should_not be_valid
    end

  end

  it "should create a correct abbreviation" do
    item = ProgramType.create!(@attr.merge(:name => "Test Name"))
    item.abbr_name.should == "TeNa"
  end


end

#describe ProgramType do
#  before (:each) do
#    @attr = { :name => "A Program Type", :description => "PT Description"}
#  end
#
#  it "should create a new instance with valid attributes" do
#    item = ProgramType.create!(@attr)
#    item.should be_valid
#  end
#
#  it "name should not be blank" do
#    item = ProgramType.new(@attr.merge(:name => ''))
#    item.should_not be_valid
#  end
#
#  it "name should be unique" do
#    item1 = ProgramType.create!(@attr)
#    item2 = ProgramType.new(@attr)
#    item2.should_not be_valid
#  end
#
#  it "description should not be blank" do
#    item = ProgramType.new(@attr.merge(:description => ''))
#    item.should_not be_valid
#  end
#
#end
