require 'spec_helper'

describe RegistrationController do

  include Devise::TestHelpers
  render_views
  before (:each) do
   @base_title = "Sierra Service Project Online Information Center"
  end

  describe "Get 'Create a Registration'" do
    before (:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin_user]
      @current_admin_user = FactoryGirl.create(:admin_user)
      sign_in @current_admin_user
      @current_admin_user.confirm!
    end
    it "should be successful" do
      get 'register'
      response.should be_success
    end

    it "should have the right title" do
      visit 'register'
      page.should have_selector("title", :content => @base_title + " | Register A Group")
    end
  end

end