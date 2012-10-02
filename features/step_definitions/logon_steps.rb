include Devise::TestHelpers

Given /^a logged on "(.*?)"$/ do |arg1|
  if @current_admin_user
    visit root_path
    click_button "Sign Out"
  end
  @current_admin_user = FactoryGirl.create("#{arg1.downcase.to_sym}_user")
  #@current_admin_user.confirm!
  @email = @current_admin_user.email
  @password = @current_admin_user.password
  visit root_path
  click_link 'Please sign in.'
  fill_in "Email", :with => @email
  fill_in "Password", :with => @password
  check 'Remember me'
  click_button 'Sign in'

end

Given /^a valid liaison logon$/ do
  liaison_logon
end

When /^I log on$/ do
  logon
end

Given /^a valid liaison logon with a registered group$/ do
  liaison_logon
  create_registration
  end

Given /^a valid liaison logon with a scheduled group$/ do
  liaison_logon
  create_registration
  create_scheduled_group
end

def create_registration
  @registration = FactoryGirl.create(:registration)
  @registration.church_id = @church1.id
  @registration.liaison_id = @liaison1.id
  @registration.save
end

def create_scheduled_group
  @scheduled_group = FactoryGirl.create(:scheduled_group)
  @scheduled_group.church_id = @church1.id
  @scheduled_group.liaison_id= @liaison1.id
  @scheduled_group.group_type_id = @registration.group_type_id
  @scheduled_group.registration_id= @registration.id
  @scheduled_group.current_counselors= @registration.requested_counselors
  @scheduled_group.current_youth= @registration.requested_youth
  @scheduled_group.current_total= @registration.requested_total
  @scheduled_group.session_id = @registration.request1
  @scheduled_group.name = @registration.name
  @scheduled_group.save
end

def liaison_logon
  if @current_admin_user
    visit root_path
    click_button "Sign out"
  end
  @current_admin_user = FactoryGirl.create(:liaison_user)
  #@current_admin_user.confirm!
  @email = @current_admin_user.email
  @password = @current_admin_user.password
  @liaison1 = FactoryGirl.create(:liaison)
  @church1 = FactoryGirl.create(:church, :active => true, :liaison_id => @liaison1.id)
  @liaison1.church_id = @church1.id
  @current_admin_user.liaison_id = @liaison1.id
  @current_admin_user.first_name = @liaison1.first_name
  @current_admin_user.last_name = @liaison1.last_name
  @liaison1.save
  @current_admin_user.save
end

def logon
  visit root_path
  click_link 'Please sign in.'
  fill_in "Email", :with => @email
  fill_in "Password", :with => @password
  check 'Remember me'
  click_button 'Sign in'
end

Then /^I see a personalized welcome message$/ do
  find("#page_title").should have_content("MySSP Information Portal. Welcome, #{@liaison1.first_name}!")
  save_and_open_page
end