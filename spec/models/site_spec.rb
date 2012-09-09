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
              :zip => "90037", :phone => "123-456-7890", :listing_priority => 1}
  end

  it "should create an instance with valid attributes" do
      site = Site.new(@attr)
      site.should be_valid
  end

  describe "Site name tests" do
    it "should require a name" do
      no_name_Site = Site.new(@attr.merge(:name => ""))
      no_name_Site.should_not be_valid
    end
  end
  
  describe "Address and city tests"  do
    it "should require an address1" do
      no_add1_Site = Site.new(@attr.merge(:address1 => ""))
      no_add1_Site.should_not be_valid
    end

    it "should require a city" do
      no_city_Site = Site.new(@attr.merge(:city => ""))
      no_city_Site.should_not be_valid
    end
  end
  
  describe "State tests" do
    
    it "should require a state" do
      no_state_Site = Site.new(@attr.merge(:state => ""))
      no_state_Site.should_not be_valid
    end

    it "should be in a valid states abbreviation" do
      invalid_state_Site = Site.new(@attr.merge(:state => "XX"))
      invalid_state_Site.should_not be_valid
    end
  end
  
  describe "zip code tests" do

    it "should require a zip code" do
      no_zip = Site.new(@attr.merge(:zip => ""))
      no_zip.should_not be_valid
    end

    it "should be 5 digits" do
      bad_zip = Site.new(@attr.merge(:zip => "1234"))
      bad_zip.should_not be_valid
    end

    it "should only be digits" do
      bad_zip = Site.new(@attr.merge(:zip => "xxxxx"))
      bad_zip.should_not be_valid
    end
  end

  describe "Phone tests" do
    it "should reject an invalid office phone" do
      bad_phone = Site.new(@attr.merge(:phone => "123-4567"))
      bad_phone.should_not be_valid
    end
  end

  describe "Listing priority tests" do
    it "should be an number" do
      item = Site.new(@attr.merge(:listing_priority => 'x'))
      item.should_not be_valid
    end
  end
end
