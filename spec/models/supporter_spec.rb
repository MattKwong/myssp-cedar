require 'spec_helper'

describe Supporter do
  before (:each) do
    @attr = { :first_name => "John", :last_name => "Smith", :address1 => "1 Test Drive", :city => "Sacramento",
              :state => "CA", :zip => "12345", :gender => "Male",
              :phone => "111-222-3333"}
  end

  #validates :first_name, :last_name, :address1, :city, :state, :email,
  #          :gender, :presence => true
  #validates_inclusion_of :state, :in => State::STATE_ABBREVIATIONS, :message => 'Invalid state.'
  #validates :zip, :presence => true, :length => { :maximum => 10, :minimum => 5 }
  #validates :phone, :length => { :maximum => 20 }

  it "There is a validation for an [email] variable that isn't in the model"

  it "should create a new instance with valid attributes" do
    item = Supporter.create!(@attr)
    item.should be_valid
  end

  describe "name tests" do
    it "first_name should not be blank" do
      item = Supporter.new(@attr.merge(:first_name => ""))
      item.should_not be_valid
    end

    it "last_name should not be blank" do
      item = Supporter.new(@attr.merge(:last_name => ""))
      item.should_not be_valid
    end
  end

  describe "address1 tests" do
    it "address1 should not be blank" do
      item = Supporter.new(@attr.merge(:address1 => ""))
      item.should_not be_valid
    end
  end

  describe "city tests" do
    it "city should not be blank" do
      item = Supporter.new(@attr.merge(:city => ""))
      item.should_not be_valid
    end
  end

  describe "email tests" do
    it "do we need email tests?"
  end

  describe "gender tests" do
    it "gender should not be blank" do
      item = Supporter.new(@attr.merge(:gender => ""))
      item.should_not be_valid
    end
  end

  describe "state tests" do
    it "state should not be blank" do
      item = Supporter.new(@attr.merge(:state => ""))
      item.should_not be_valid
    end

    it "state should be valid abbreviation" do
      item = Supporter.new(@attr.merge(:state => "XYZ"))
      item.should_not be_valid
    end
  end

  describe "zip tests" do
    it "zip should not be blank" do
      item = Supporter.new(@attr.merge(:zip => ""))
      item.should_not be_valid
    end

    it "zip should be at least 5 characters" do
      item = Supporter.new(@attr.merge(:zip => "1234"))
      item.should_not be_valid
    end

    it "zip should be no more than 10 characters" do
      item = Supporter.new(@attr.merge(:zip => "1234567890 123"))
      item.should_not be_valid
    end
  end

  describe "phone tests" do
    it "phone should not be blank" do
      item = Supporter.new(@attr.merge(:phone => ""))
      item.should_not be_valid
    end

    it "phone should be no more than 20 characters" do
      item = Supporter.new(@attr.merge(:phone => "1234567890 1234567890 1234567890"))
      item.should_not be_valid
    end
  end

end
