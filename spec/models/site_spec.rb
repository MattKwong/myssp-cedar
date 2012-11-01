# == Schema Information
#
# Table name: sites
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  address1         :string(255)
#  address2         :string(255)
#  city             :string(255)
#  state            :string(255)
#  zip              :string(255)
#  phone            :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  listing_priority :integer
#  active           :boolean
#  summer_domestic  :boolean
#  abbr             :string(255)
#

require 'spec_helper'

describe Site do
  before (:each) do
    @attr = { :name => "Site Name", :address1 => "4410 S. Budlong Avenue", :city => "Los Angeles", :state => "CA",
              :zip => "90037", :phone => "123-456-7890", :listing_priority => 1, :abbr => "SN"}
  end

  #validates :name, :address1, :city, :state, :zip, :listing_priority, :abbr, :presence => true
  #
  #validates :state, :abbr, :length => { :is => 2}
  #validates_inclusion_of :state, :in => State::STATE_ABBREVIATIONS, :message => 'Invalid state.'
  #validates :zip,   :length => { :is => 5}, :numericality => true
  #
  #validates_format_of :phone, :with => /\A[0-9]{3}-[0-9]{3}-[0-9]{4}/,
  #                    :message => 'Please enter phone numbers in the 123-456-7890 format.'
  #validates :listing_priority, :numericality => true

  it "should create an instance with valid attributes" do
      item = Site.new(@attr)
      item.should be_valid
  end

  describe "name tests" do

    it "should require a name" do
      item = Site.new(@attr.merge(:name => ""))
      item.should_not be_valid
    end

  end

  describe "address tests"  do

    it "should require an address1" do
      item = Site.new(@attr.merge(:address1 => ""))
      item.should_not be_valid
    end

  end

  describe "city tests" do

    it "should require a city" do
      item = Site.new(@attr.merge(:city => ""))
      item.should_not be_valid
    end

  end

  describe "state tests" do

    it "should require a state" do
      item = Site.new(@attr.merge(:state => ""))
      item.should_not be_valid
    end

    it "should not be less than 2 characters" do
      item = Site.new(@attr.merge(:state => "C"))
      item.should_not be_valid
    end

    it "should not be more than 2 characters" do
      item = Site.new(@attr.merge(:state => "CAL"))
      item.should_not be_valid
    end

    it "should be in a valid states abbreviation" do
      item = Site.new(@attr.merge(:state => "XX"))
      item.should_not be_valid
    end
  end

  describe "Zip code tests" do

    it "should require a zip code" do
      item = Site.new(@attr.merge(:zip => ""))
      item.should_not be_valid
    end

    it "should not be less than 5 digits" do
      item = Site.new(@attr.merge(:zip => "1234"))
      item.should_not be_valid
    end

    it "should not be greater than 5 digits" do
      item = Site.new(@attr.merge(:zip => "123456"))
      item.should_not be_valid
    end

    it "should only be digits/numbers" do
      item = Site.new(@attr.merge(:zip => "1234x"))
      item.should_not be_valid
    end

  end

  describe "Phone number tests" do

    it "should reject a phone number of wrong format" do
      item = Site.new(@attr.merge(:phone => "(123)456-7890"))
      item.should_not be_valid
    end

    it "should reject a phone number of with letters" do
      item = Site.new(@attr.merge(:phone => "a23-b56-c890"))
      item.should_not be_valid
    end

  end

  describe "Listing priority tests" do

    it "should not be empty" do
      item = Site.new(@attr.merge(:listing_priority => ''))
      item.should_not be_valid
    end

    it "should be an number" do
      item = Site.new(@attr.merge(:listing_priority => 'x'))
      item.should_not be_valid
    end

  end

  describe "Abbreviation (of site name) tests" do

    it "should not be empty" do
      item = Site.new(@attr.merge(:abbr => ""))
      item.should_not be_valid
    end

    it "should not be less than 2 characters" do
      item = Site.new(@attr.merge(:state => "A"))
      item.should_not be_valid
    end

    it "should not be more than 2 characters" do
      item = Site.new(@attr.merge(:state => "ALS"))
      item.should_not be_valid
    end

  end

end