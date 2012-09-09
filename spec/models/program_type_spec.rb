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
    @attr = { :name => "A Program Type", :description => "PT Description"}
  end

  it "should create a new instance with valid attributes" do
    item = ProgramType.create!(@attr)
    item.should be_valid
  end

  it "name should not be blank" do
    item = ProgramType.new(@attr.merge(:name => ''))
    item.should_not be_valid
  end

  it "name should be unique" do
    item1 = ProgramType.create!(@attr)
    item2 = ProgramType.new(@attr)
    item2.should_not be_valid
  end

  it "description should not be blank" do
    item = ProgramType.new(@attr.merge(:description => ''))
    item.should_not be_valid
  end

end
