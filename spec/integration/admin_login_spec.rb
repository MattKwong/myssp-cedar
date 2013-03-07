#require './../spec_helper'
require 'spec_helper'

feature "Signing in" do
  before :each do
    TestUser = FactoryGirl.create(:admin_user)
    #TestRole = FactoryGirl.create(:user_role)
  end

  scenario "access sign in page by direct link" do
    visit '/admin_users/sign_in'
  end

  scenario "access sign in page by clicking the link" do
    visit '/'
    click_link 'Please sign in.'
    current_path.should == '/admin_users/sign_in'
  end

  scenario "valid admin user logs in" do
    visit '/'
    click_link 'Please sign in.'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    #save_and_open_page
    click_button('Sign in')
    current_path.should == '/admin' and page.should have_content("Signed in successfully.")
  end

  scenario "invalid sign in (empty email)" do#, :js => :true do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => ''
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    current_path.should == '/admin_users/sign_in' and page.should have_content("Invalid email or password.")
  end

  scenario "invalid sign in (empty password)" do#, :js => :true do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => ''
    click_button('Sign in')
    #save_and_open_page
    current_path.should == '/admin_users/sign_in' and page.should have_content("Invalid email or password.")
  end

  scenario "invalid sign in (empty email and password)" do#, :js => :true do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => ''
    fill_in 'Password', :with => ''
    click_button('Sign in')
    #save_and_open_page
    current_path.should == '/admin_users/sign_in' and page.should have_content("Invalid email or password.")
  end

  scenario "valid sign in then sign out" do#, :js => :true do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    #save_and_open_page
    click_button('Sign in')
    click_link('Logout')
    current_path.should == '/' and page.should have_content("Signed out successfully.")
  end

end
