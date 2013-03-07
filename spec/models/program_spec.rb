require 'spec_helper'

# == Schema Information
#
# Table name: programs
#
#  id              :integer          not null, primary key
#  active          :boolean
#  created_at      :timestamp
#  end_date        :date
#  name            :varchar(255)
#  program_type_id :integer
#  short_name      :varchar(255)
#  site_id         :integer
#  start_date      :date
#  updated_at      :timestamp
#

describe Program do

  before (:each) do
    @attr = { :name => "Program", :site_id => Site.find_by_name("Test Site 3").id, :start_date => Date.today+3,
              :end_date => Date.today+4, :program_type_id =>  ProgramType.find_by_name("Summer Domestic").id,
              :active => true}
  end

    #validates :name, :presence => true, :uniqueness => true
    #validates :short_name, :presence => true, :uniqueness => true
    #validates :site_id, :presence => true
    #validates :start_date, :presence => true
    #validates :end_date, :presence => true
    #validates :program_type_id, :presence => true
    #validates :active, :inclusion => [true, false]
    #validate :start_date_before_end_date
    # NOT THIS ONE YET
    #validate :start_date_not_in_past

  it "should create a new instance with valid attributes" do
    #relies on seed data for a program type
    item = Program.new(@attr)
    item.should be_valid
  end

  describe "name/short name tests" do

    it "should automatically generate a name" do
      item = Program.new(@attr.merge(:name => ""))
      item.should be_valid
    end

    it "should be unique" do
      item1 = Program.create!(@attr.merge(:name => ""))
      item2 = Program.new(@attr.merge(:name => ""))
      item2.should_not be_valid
    end

    it "should generate correct name" do
      item1 = Program.create!(@attr.merge(:name => ""))
      item1.name.should == "Test Site 3 Summer Domestic 2013"
    end

    it "should generate correct short_name" do
      item1 = Program.create!(@attr.merge(:short_name => ""))
      item1.short_name.should == "SN SuDo 13"
    end

  end

  it "should require a site_id (and thereby a site to link to)" do
    expect { item = Program.create!(@attr.merge(:site_id => "")) }.to raise_error
    #item = Program.create!(@attr.merge(:site_id => ""))
    #item.should_not be_valid
  end

  it "should require a start date" do
    expect { item = Program.create!(@attr.merge(:start_date => "")) }.to raise_error
    #item = Program.new(@attr.merge(:start_date => ""))
    #item.should_not be_valid
  end

  it "should require a end date" do
    #expect { item = Program.create!(@attr.merge(:end_date => "")) }.to raise_error
    item = Program.new(@attr.merge(:end_date => ""))
    item.should_not be_valid
  end

  it "should require a program type id" do
    expect { item = Program.create!(@attr.merge(:program_type_id => "")) }.to raise_error
    #item = Program.new(@attr.merge(:program_type_id => ""))
    #item.should_not be_valid
  end

  it "should require active boolean" do
    #expect { item = Program.create!(@attr.merge(:active => "")) }.to raise_error
    item = Program.new(@attr.merge(:active => ""))
    item.should_not be_valid
  end

  it "summer_domestic? should return true if it is a Summer Domestic Program" do
    item = Program.new(@attr)
    item.summer_domestic?.should == true
  end

  pending "How to test total days?" do
    item = Program.new(@attr)
    puts(item.total_days)
  end

  it "start date should not be in the past" do
    #expect { item = Program.create!(@attr.merge(:active => "")) }.to raise_error
    item = Program.new(@attr.merge(:end_date => Date.today-3))
    item.should_not be_valid
  end

end
