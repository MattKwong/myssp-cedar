# == Schema Information
#
# Table name: churches
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  city           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  liaison_id     :integer
#  address2       :string(255)
#  state          :string(255)
#  zip            :string(255)
#  office_phone   :string(255)
#  fax            :string(255)
#  email1         :string(255)
#  address1       :string(255)
#  active         :boolean
#  registered     :boolean
#  church_type_id :integer
#

require 'spec_helper'

describe Church do

  before (:each) do
    if Church.find_by_name("First Church")
      Church.find_by_name("First Church").delete
    end
    @attr = { :name => "First Church", :address1 => "4410 S. Budlong Avenue", :city => "Los Angeles", :state => "CA",
              :zip => "90037", :email1 => "info@example.com", :registered => false,
              :office_phone => "123-456-7890", :fax => "123-456-7890", :liaison_id => 1, :active => true, :church_type_id => 1 }
  end

  it "should create an instance with valid attributes" do
      item = Church.new(@attr)
      item.should be_valid
  end

  describe "name tests" do

    it "should require a name" do
      item = Church.new(@attr.merge(:name => ""))
      item.should_not be_valid
    end

    it "should reject a short name (name < 6 characters)" do
      short_name = "a" * 5
      item = Church.new(@attr.merge(:name => short_name))
      item.should_not be_valid
    end

    it "should reject a long name (name > 45 characters)" do
      long_name = "a" * 46
      item = Church.new(@attr.merge(:name => long_name))
      item.should_not be_valid
    end

    it "name should be unique" do
      item1 = Church.create!(@attr.merge(:name => 'Testing Name'))
      item2 = Church.new(@attr.merge(:name => 'Testing Name'))
      item2.should_not be_valid
    end

  end
  
  describe "address tests"  do

    it "should require an address1" do
      item = Church.new(@attr.merge(:address1 => ""))
      item.should_not be_valid
    end

  end

  describe "city tests" do

    it "should require a city" do
      no_city_church = Church.new(@attr.merge(:city => ""))
      no_city_church.should_not be_valid
    end

  end
  
  describe "State tests" do

    it "should require a state" do
      no_state_church = Church.new(@attr.merge(:state => ""))
      no_state_church.should_not be_valid
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
      invalid_state_church = Church.new(@attr.merge(:state => "XX"))
      invalid_state_church.should_not be_valid
    end

  end
  
  describe "zip code tests" do

    it "should require a zip code" do
      no_zip = Church.new(@attr.merge(:zip => ""))
      no_zip.should_not be_valid
    end

    it "should not be less than 5 digits" do
      item = Site.new(@attr.merge(:zip => "1234"))
      item.should_not be_valid
    end

    it "should not be greater than 5 digits" do
      item = Site.new(@attr.merge(:zip => "123456"))
      item.should_not be_valid
    end

    it "should only be digits" do
      bad_zip = Church.new(@attr.merge(:zip => "1234x"))
      bad_zip.should_not be_valid
    end

  end

  describe "email1 tests" do

    it "should allow a blank email" do
      no_email = Church.new(@attr.merge(:email1 => ""))
      no_email.should be_valid
    end

    it "should reject an invalid email format (1)" do
      bad_email = Church.new(@attr.merge(:email1 => "info@example"))
      bad_email.should_not be_valid
    end

    it "should reject an invalid email format (2)" do
      bad_email = Church.new(@attr.merge(:email1 => "info@example.com1"))
      bad_email.should_not be_valid
    end

    it "name should be unique" do
      item1 = Church.create!(@attr.merge(:email1 => 'test@example.com'))
      item2 = Church.new(@attr.merge(:email1 => 'test@example.com'))
      item2.should_not be_valid
    end

    #it "should reject a duplicate email" do
    #  good_email = Church.new(@attr)
    #  good_email.save
    #  dup_email = Church.new(@attr.merge(:name => "Duplicate email church"))
    #  dup_email.should_not be_valid
    #end
  end
  
  describe "office phone tests" do

    it "should have an office phone" do
      no_phone = Church.new(@attr.merge(:office_phone => ""))
      no_phone.should_not be_valid
    end

    it "should reject a phone number of wrong format" do
      item = Site.new(@attr.merge(:office_phone => "(123)456-7890"))
      item.should_not be_valid
    end

    it "should reject a phone number of with letters" do
      item = Site.new(@attr.merge(:office_phone => "a23-b56-c890"))
      item.should_not be_valid
    end

  end

  describe "fax phone tests" do

    it "should allow an empty fax" do
      item = Site.new(@attr.merge(:fax => ""))
      item.should be_valid
    end

    it "should reject a phone number of wrong format" do
      item = Site.new(@attr.merge(:fax => "(123)456-7890"))
      item.should_not be_valid
    end

    it "should reject a phone number of with letters" do
      item = Site.new(@attr.merge(:fax => "a23-b56-c890"))
      item.should_not be_valid
    end

  end

end
