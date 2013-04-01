require 'spec_helper'

describe LoginRequest do
  before (:each) do
    if LoginRequest.find_by_email("test_user@spp.org")
      LoginRequest.find_by_email("test_user@spp.org").delete
    end
    @attr = { :first_name => "Test", :last_name => "User", :address1 => "4410 S. Budlong Avenue", :city => "Los Angeles", :state => "CA",
              :zip => "90037", :email => "test_user@ssp.org", :phone_number => "916-488-6441", :phone_number_type => "Mobile",
              :alt_phone_number => "916-488-6441", :alt_phone_number_type => "Work", :user_created => false, :approved => false,
              :church_name => "First Community Church", :church_address1 => "100 First Street", :church_city => "Los Angeles",
              :church_state => "CA", :church_zip => "99999", :church_office_fax => "213-123-1234", :church_office_phone => "213-123-1234"
               }
  end

  describe "Valid Login Request" do
    it "should be valid" do
      LoginRequest.new(@attr).should be_valid
    end
  end
  describe "Login required field - user info" do
    it "should require a first name" do
      LoginRequest.new(@attr.merge(:first_name => "")).should_not be_valid
    end
    it "should require a last name" do
      LoginRequest.new(@attr.merge(:last_name => "")).should_not be_valid
    end
    it "should require an address" do
      LoginRequest.new(@attr.merge(:address1 => "")).should_not be_valid
    end
    it "should require a city" do
      LoginRequest.new(@attr.merge(:city => "")).should_not be_valid
    end
    it "should require a state" do
      LoginRequest.new(@attr.merge(:state => "")).should_not be_valid
    end
    it "should require a zip" do
      LoginRequest.new(@attr.merge(:zip => "")).should_not be_valid
    end
    it "should require an email" do
      LoginRequest.new(@attr.merge(:email => "")).should_not be_valid
    end
  end

  describe "Login field validity tests" do
    it "should require a valid zip" do
      LoginRequest.new(@attr.merge(:zip => "1234")).should_not be_valid
    end
    it "should require a valid zip" do
      LoginRequest.new(@attr.merge(:zip => "1234s")).should_not be_valid
    end
    it "should require a valid state abbreviation" do
      LoginRequest.new(@attr.merge(:state => "XX")).should_not be_valid
    end
    it "should require a valid email" do
      LoginRequest.new(@attr.merge(:email => "rick@rick")).should_not be_valid
    end
    it "should reject an ill-formed phone number" do
      LoginRequest.new(@attr.merge(:phone_number => "800-800-800")).should_not be_valid
    end
    it "should reject an ill-formed alt phone number" do
      LoginRequest.new(@attr.merge(:alt_phone_number => "800-800-800")).should_not be_valid
    end
    it "should reject an invalid phone number type" do
      LoginRequest.new(@attr.merge(:phone_number_type => "Bad Phone")).should_not be_valid
    end
    it "should reject an invalid alt phone number type" do
      LoginRequest.new(@attr.merge(:alt_phone_number_type => "Bad Phone")).should_not be_valid
    end
    it "should reject a phone number type being used twice" do
      LoginRequest.new(@attr.merge(:phone_number_type => "Home", :alt_phone_number_type => "Home")).should_not be_valid
    end
    it "should reject an alt phone number type with a blank number" do
      LoginRequest.new(@attr.merge(:alt_phone_number => "", :alt_phone_number_type => "Home")).should_not be_valid
    end
    it "should reject an alt phone number with a blank number type" do
      LoginRequest.new(@attr.merge(:alt_phone_number => "800-123-1234", :alt_phone_number_type => "")).should_not be_valid
    end
    it "should accept a phone number without separators" do
      LoginRequest.new(@attr.merge(:phone_number => "8001231234")).should be_valid
    end
    it "should accept a phone number with 1- in front" do
      LoginRequest.new(@attr.merge(:phone_number => "1-800-123-1234")).should be_valid
    end
    it "should accept phone number with period as separator" do
      LoginRequest.new(@attr.merge(:phone_number => "800.123.1234")).should be_valid
    end
    it "should accept a alt phone number without separators" do
      LoginRequest.new(@attr.merge(:alt_phone_number => "8001231234")).should be_valid
    end
    it "should accept a alt phone number with 1- in front" do
      LoginRequest.new(@attr.merge(:alt_phone_number => "1-800-123-1234")).should be_valid
    end
    it "should accept alt phone number with non-dash separator" do
      LoginRequest.new(@attr.merge(:alt_phone_number => "800 123 1234")).should be_valid
    end
    it "should accept a church office number without separators" do
      LoginRequest.new(@attr.merge(:church_office_phone => "8001231234")).should be_valid
    end
    it "should accept a church office phone with 1- in front" do
      LoginRequest.new(@attr.merge(:church_office_phone => "1-800-123-1234")).should be_valid
    end
    it "should accept church office phone with non-dash separator" do
      LoginRequest.new(@attr.merge(:church_office_phone => "800 123 1234")).should be_valid
    end
    it "should accept a church office fax without separators" do
      LoginRequest.new(@attr.merge(:church_office_fax => "8001231234")).should be_valid
    end
    it "should accept a church office fax with 1- in front" do
      LoginRequest.new(@attr.merge(:church_office_fax => "1-800-123-1234")).should be_valid
    end
    it "should accept church office fax with non-dash separator" do
      LoginRequest.new(@attr.merge(:church_office_fax=> "800 123 1234")).should be_valid
    end
  end

  describe "Required field - church info" do
    it "should require a church name" do
      LoginRequest.new(@attr.merge(:church_name => "")).should_not be_valid
    end
    it "should require an address" do
      LoginRequest.new(@attr.merge(:church_address1 => "")).should_not be_valid
    end
    it "should require a city" do
      LoginRequest.new(@attr.merge(:church_city => "")).should_not be_valid
    end
    it "should require a state" do
      LoginRequest.new(@attr.merge(:church_state => "")).should_not be_valid
    end
    it "should require a zip" do
      LoginRequest.new(@attr.merge(:church_zip => "")).should_not be_valid
    end
  end

  describe "Church field validity tests" do
    it "should require a valid zip" do
      LoginRequest.new(@attr.merge(:church_zip => "1234")).should_not be_valid
    end
    it "should require a valid zip" do
      LoginRequest.new(@attr.merge(:church_zip => "1234s")).should_not be_valid
    end
    it "should require a valid state abbreviation" do
      LoginRequest.new(@attr.merge(:church_state => "XX")).should_not be_valid
    end
    it "should reject an ill-formed phone number" do
      LoginRequest.new(@attr.merge(:church_office_phone => "800-800-800")).should_not be_valid
    end
    it "should reject an ill-formed fax number" do
      LoginRequest.new(@attr.merge(:church_office_fax => "800-800-80080")).should_not be_valid
    end
  end


end