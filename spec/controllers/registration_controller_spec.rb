require 'spec_helper'

describe RegistrationController do

  include Devise::TestHelpers
  render_views
  before (:each) do
   @base_title = "Sierra Service Project Online Information Center"
  end

  before (:each) do
    @current_admin_user = AdminUser.find(1)
    sign_in @current_admin_user
  end

  describe "Get 'Group Manager'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end

    it "should have the right title" do
      get 'index'
      response.should have_selector("title", :content => @base_title + " | Manage Groups")
    end
  end

  describe "Get 'Create a Registration'" do
    it "should be successful" do
      get 'register'
      response.should be_success
    end

    it "should have the right title" do
      get 'register'
      response.should have_selector("title", :content => @base_title + " | Register A Group")
    end
  end

end