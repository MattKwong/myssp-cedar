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
  if @current_admin_user
    visit root_path
    click_button "Sign Out"
  end
  @current_admin_user = FactoryGirl.create(:liaison_user)
  #@current_admin_user.confirm!
  @email = @current_admin_user.email
  @password = @current_admin_user.password
end

When /^I log on$/ do
  logon
end



def logon
  visit root_path
  click_link 'Please sign in.'
  fill_in "Email", :with => @email
  fill_in "Password", :with => @password
  check 'Remember me'
  click_button 'Sign in'
end