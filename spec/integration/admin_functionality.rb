require './../spec_helper'

feature "Logged in Admin" do
  before :each do
    TestUser = FactoryGirl.create(:admin_user)
    TestRole = FactoryGirl.create(:user_role)
    #TestRole2 = FactoryGirl.create(:user_role2)
  end

  scenario "valid admin user logs in" do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    current_path.should == '/admin' and page.should have_content("Signed in successfully.")
  end

  scenario "can access Churches page by direct link" do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    visit '/admin/churches'
  end

  scenario "can access Churches page by clicking link" do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    click_link('Churches')
    current_path.should == '/admin/churches'
  end

  scenario "can access Liaisons page by direct link" do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    visit '/admin/liaisons'
  end

  scenario "can access Liaisons page by clicking link" do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    click_link('Liaisons')
    current_path.should == '/admin/liaisons'
  end

  pending scenario "CC Payment tests" do
    # Not sure what CC Payment is
  end

  scenario "can access Purchases page by direct link" do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    visit '/admin/purchases'
  end

  scenario "can access Purchases page by clicking link" do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    click_link('Purchases')
    current_path.should == '/admin/purchases'
  end

  scenario "can access Group > Payments page by direct link" do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    visit '/admin/payments'
  end

  scenario "can access Group > Payments page by clicking link" do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    click_link('Payments')
    current_path.should == '/admin/payments'
  end

  scenario "can access Groups > Scheduled Groups page by direct link" do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    visit '/admin/scheduled_groups'
  end

  scenario "can access Groups > Scheduled Groups page by clicking link" do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    click_link('Scheduled Groups')
    current_path.should == '/admin/scheduled_groups'
  end

  pending scenario "Check that all groups are shown" do
    # Not sure yet
  end

  scenario "can access Users and Logs > Admin Users page by direct link" do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    visit '/admin/admin_users'
  end

  scenario "can access Users and Logs > Admin Users page by clicking link" do
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    click_link('Admin Users')
    current_path.should == '/admin/admin_users'
  end

  pending scenario "Check that all admin users are shown" do
    # Not sure yet
  end

  pending scenario "can 'inactivate' user" do
    # Make a user to test with
    @attr = { :email => "deactivate@me.com", :first_name => "Test", :last_name => "User",
              :user_role_id => 2, :username => "Deactivate"  }
    TargetUser = AdminUser.new(@attr)
    visit '/admin_users/sign_in'
    fill_in 'Email', :with => TestUser.email
    fill_in 'Password', :with => TestUser.password
    click_button('Sign in')
    #save_and_open_page
    click_link('Admin Users')
    fill_in 'q_email', :with => TargetUser.email
    click_button('filter')
    click_link('Inactivate)
    current_path.should == '/admin/admin_users'
  end

end
