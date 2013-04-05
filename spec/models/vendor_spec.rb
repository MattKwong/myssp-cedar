require 'spec_helper'

describe Vendor do
  before (:each) do
    @attr = { :name => "Vendor Name", :address => "1 Test Drive", :city => "Sacramento", :state => "CA", :zip => "12345",
              :phone => "111-222-3333", :site_id => Site.find_by_name("Test Site 3").id}
  end

  #attr_accessible :name, :address, :city, :state, :zip, :contact, :phone, :notes, :site_id
  #
  #validates :name,  :presence => true,
  #          :length => { :within => 6..45}
  #validates :address, :presence => true
  #validates :city, :presence => true
  #validates_inclusion_of :state, :in => State::STATE_ABBREVIATIONS, :message => 'Invalid state.'
  #validates :zip, :presence => true, :length => { :maximum => 10, :minimum => 5 }
  #validates :phone, :length => { :maximum => 20 }

  it "should create a new instance with valid attributes" do
    item = Vendor.create!(@attr)
    item.should be_valid
  end

  describe "name tests" do
    it "name should not be blank" do
      no_name = Vendor.new(@attr.merge(:name => ""))
      no_name.should_not be_valid
    end

    it "name should be at least 6 characters" do
      expect { item = Vendor.create!(@attr.merge(:name => "12345")) }.to raise_error
      #item.should_not be_valid
    end

    it "name should be <= 40 characters" do
      expect { item = Vendor.create!(@attr.merge(:name => "0123456789 0123456789 0123456789 0123456789 0123456789")) }.to raise_error
      #item.should_not be_valid
    end

  end

  it "should have an address" do
    item = Vendor.new(@attr.merge(:address => ""))
    item.should_not be_valid
  end

  it "should have a city" do
    item = Vendor.new(@attr.merge(:city => ""))
    item.should_not be_valid
  end

  it "should have a valid state abbreviation" do
    item = Vendor.new(@attr.merge(:state => "POP"))
    item.should_not be_valid
  end

  describe "zip tests" do
    it "should not be blank" do
      item = Vendor.new(@attr.merge(:zip => ""))
      item.should_not be_valid
    end

    it "should be at >= 5 characters" do
      item = Vendor.new(@attr.merge(:zip => "1234"))
      item.should_not be_valid
    end

    it "should be at < 10 characters" do
      item = Vendor.new(@attr.merge(:zip => "0123456789 0123456789"))
      item.should_not be_valid
    end
  end

  describe "phone tests" do
    it "phone must be less than 20" do
      item = Vendor.new(@attr.merge(:phone => "0123456789 0123456789 0123456789"))
      item.should_not be_valid
    end
    it "should there be more constraints on phone?"
  end
end
