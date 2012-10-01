require 'spec_helper'
require 'support/controller_macros'

describe ApplicationController do
  include Devise::TestHelpers
  render_views
  describe "Admin Login" do
    before (:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin_user]
      @current_admin_user = FactoryGirl.create(:admin_user)
      sign_in @current_admin_user
      @current_admin_user.confirm!
    end

    it "should have a current user" do
      subject.current_admin_user.should_not be_nil
    end

    it "current user should be an admin" do
      subject.current_admin_user.admin?.should be_true
    end

    end

  describe "Liaison Login" do
    before (:each) do
      @request.env["devise.mapping"] = Devise.mappings[:liaison_user]
      @current_admin_user = FactoryGirl.create(:liaison_user)
      sign_in @current_admin_user
      @current_admin_user.confirm!

#need to create a liaison instance, linked to admin and linked to church
      @church1 = FactoryGirl.create(:church, :active => true, :liaison_id => @current_admin_user.id )
      @church2 = FactoryGirl.create(:church, :name => 'Test Church 2', :email1 => 'church2@church.com')
    end

    it "should have a current user" do
      subject.current_admin_user.should_not be_nil
    end

    it "current user should be an liaison" do
      subject.current_admin_user.liaison?.should be_true
    end
    #
    #it "should see personalized welcome page at login" do
    #  response.should be_success
    #  save_and_open_page
    #  page.should have_selector("title", :content => "Welcome")
    #end

    it "current user should see its church" do
      subject.current_admin_user.liaison.church.should_not be_nil
      subject.current_admin_user.liaison.church.name.should == 'Carmichael Test Church'
    end

  end


#should test routes to admin, liaison and staff logons
#should test that activity log is written to

end