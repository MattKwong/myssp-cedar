# == Schema Information
#
# Table name: registrations
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  liaison_id           :integer
#  created_at           :datetime
#  updated_at           :datetime
#  request1             :integer
#  request2             :integer
#  request3             :integer
#  request4             :integer
#  request5             :integer
#  request6             :integer
#  request7             :integer
#  request8             :integer
#  request9             :integer
#  request10            :integer
#  requested_counselors :integer
#  requested_youth      :integer
#  requested_total      :integer
#  scheduled            :boolean
#  comments             :text
#  amount_due           :decimal(, )
#  amount_paid          :decimal(, )
#  payment_method       :string(255)
#  payment_notes        :text
#  group_type_id        :integer
#  church_id            :integer
#  registration_step    :string(255)
#

require 'spec_helper'

describe "Registration" do
    before (:each) do
      @attr = { :name => "Group Name", :request1 => 1, :request2 => 2, :request3 => 3,
                  :request4 => 4, :request5 => 5, :request6 => 6, :request7 => 7,
                  :request8 => 8, :request9 => 9, :request10 => 10,
                  :requested_counselors => 2, :requested_youth => 10,
                  :amount_due => 1000.00, :amount_paid => 200.00, :payment_method => "Check",
                  :scheduled => false}
    end

    it "should create an instance given valid attributes" do
      item = Registration.new(@attr)
      item.should be_valid
    end

    describe "basic tests" do
      it "should require a name" do
        item = Registration.new(@attr.merge(:name => ""))
        item.should_not be_valid
      end

      it "should require proper requested_youth integer" do
        item = Registration.new(@attr.merge(:requested_youth => 1.1))
        item.should_not be_valid
      end

      it "should require proper requested_counselors integer" do
        item = Registration.new(@attr.merge(:requested_counselors => 1.1))
        item.should_not be_valid
      end
    end

    describe "request priority logic tests" do

      it "should require a request1" do
        item = Registration.new(@attr.merge(:request1 => nil, :registration_step => 'Step 2' ))
        item.should_not be_valid
      end

      it "should require that requests be in sequence" do
        item = Registration.new(@attr.merge(:request5 => 2, :registration_step => 'Step 2'))
        item.should_not be_valid
      end

      it "should require that there be no duplicate requests" do
        item = Registration.new(@attr.merge(:request4 => 7, :registration_step => 'Step 2'))
        item.should_not be_valid
      end
      it "should treat 0 the same as nil" do
        item = Registration.new(@attr.merge(:request9 => 0, :request10 => 0, :registration_step => 'Step 2'))
        item.should be_valid
      end
    end
  end

