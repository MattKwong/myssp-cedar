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
    end

    it "should have a current user" do
      subject.current_admin_user.should_not be_nil
    end

    it "current user should be an liaison" do
      subject.current_admin_user.liaison?.should be_true
    end

  end

#should test routes to admin, liaison and staff logons
#should test that activity log is written to

end