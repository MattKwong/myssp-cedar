require 'spec_helper'


describe PagesController do
  include Devise::TestHelpers
  render_views

    before (:each) do
      @base_title = "SSP Online Information Center | "
      @request.env["devise.mapping"] = Devise.mappings[:admin_user]
      @current_admin_user = FactoryGirl.create(:admin_user)
      sign_in @current_admin_user
      @current_admin_user.confirm!
    end

    #login_admin

  it "should have a current user" do
    subject.current_admin_user.should_not be_nil
  end

  describe "GET 'home'" do
    it "should be successful" do
      visit 'home'
      response.should be_success
      #save_and_open_page
    end

    it "should have the right title" do
      visit 'home'
      page.should have_selector('title', :content => (@base_title + "Welcome"))
      #save_and_open_page
    end
  end

  describe "GET 'contact'" do
    @base_title = "SSP Information Center"
    it "should be successful" do
      get 'contact'
      response.should be_success
    end

    it "should have the right title" do
      visit 'contact'
      page.should have_selector("title", :content => (@base_title + "Contact"))
    end
  end
  describe "GET 'about'" do
    @base_title = "SSP Information Center"
    it "should be successful" do
      visit 'about'
      response.should be_success
    end

    it "should have the right title" do
      visit 'about'
      page.should have_selector("title", :content => (@base_title + "About"))
    end
  end

  describe "GET 'help'" do
    @base_title = "SSP Information Center"
    it "should be successful" do
      get 'help'
      response.should be_success
    end

    it "should have the right title" do
      visit 'help'
      page.should have_selector("title", :content => (@base_title + "Help "))
    end
  end


end