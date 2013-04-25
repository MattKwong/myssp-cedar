# == Schema Information
#
# Table name: reminders
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  seq_number  :integer
#  first_line  :string(255)
#  second_line :string(255)
#  active      :boolean
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe Reminder do
  before (:each) do
    @attr = { :active => "true", :first_line => "First line", :name => "Reminder Name", :second_line => "second line",
    :seq_number => 12}
  end

  #attr_accessible :active, :first_line, :name, :second_line, :seq_number
  #
  #validates :name, :first_line, :second_line,
  #          :length => { :within => 6..40}
  #validates :name,:uniqueness => true, :allow_blank => false
  #validates :first_line, :presence => true
  #validates_numericality_of :seq_number,  :allow_blank => false, :only_integer =>  true, :less_than => 100,
  #                          :greater_than_or_equal_to => 0

  it "should create a new instance with valid attributes" do
    item = Reminder.create!(@attr)
    item.should be_valid
  end

  describe "name tests" do
    it "should have a name" do
      item = Reminder.new(@attr.merge(:name => ""))
      item.should_not be_valid
    end

    it "should have a unique name" do
      item1 = Reminder.create!(@attr.merge(:name => "123456"))
      item2 = Reminder.new(@attr.merge(:name => "123456"))
      item2.should_not be_valid
    end

    it "should have a name >= length 6" do
      item = Reminder.new(@attr.merge(:name => "12345"))
      item.should_not be_valid
    end

    it "should have a name <= length 40" do
      item = Reminder.new(@attr.merge(:name => "1234567890 1234567890 1234567890 1234567890"))
      item.should_not be_valid
    end
  end

  describe "first_line tests" do

    it "should not be blank" do
      item = Reminder.new(@attr.merge(:first_line => ""))
      item.should_not be_valid
    end

    it "should have length >=  6" do
      item = Reminder.new(@attr.merge(:first_line => "12345"))
      item.should_not be_valid
    end

    it "should have length <= 40" do
      item = Reminder.new(@attr.merge(:first_line => "1234567890 1234567890 1234567890 1234567890"))
      item.should_not be_valid
    end

  end

  describe "second_line tests" do

    it "it should not be blank" do
      item = Reminder.new(@attr.merge(:second_line => ""))
      item.should_not be_valid
    end

    it "should have length >=  6" do
      item = Reminder.new(@attr.merge(:second_line => "12345"))
      item.should_not be_valid
    end

    it "should have length <= 40" do
      item = Reminder.new(@attr.merge(:second_line => "1234567890 1234567890 1234567890 1234567890"))
      item.should_not be_valid
    end

  end

  describe "seq_number tests" do

    it "should not be blank" do
      item = Reminder.new(@attr.merge(:seq_number => ""))
      item.should_not be_valid
    end

    it "should be an integer (1)" do
      item = Reminder.new(@attr.merge(:seq_number => 4.5))
      item.should_not be_valid
    end

    it "should be an integer (2)" do
      item = Reminder.new(@attr.merge(:seq_number => "c"))
      item.should_not be_valid
    end

    it "should be >= 0" do
      item = Reminder.new(@attr.merge(:seq_number => -1))
      item.should_not be_valid
    end

    it "should be < 100" do
      item = Reminder.new(@attr.merge(:seq_number => 100))
      item.should_not be_valid
    end

  end

end
