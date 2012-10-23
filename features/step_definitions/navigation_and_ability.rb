include Devise::TestHelpers

When /^I do nothing$/ do

end

Then /^I see a "(.*?)" menu item$/ do |arg1|
  save_and_open_page
  find("##{arg1.downcase}").should have_content(arg1)

end

Then /^I see the "(.*?)" page$/ do |arg1|
  #save_and_open_page
  find("#page_title").should have_content(arg1)
end

And /^I see my name on the menu bar$/ do
  find("#utility_nav").should have_content(@current_admin_user.name)
end

When /^I click on "(.*?)"$/ do |arg1|
  #save_and_open_page
  click_link arg1

end

And /^I see a "(.*?)" button$/ do |arg1|
  find("#titlebar_right").should have_content(arg1)
end

When /^I visit "(.*?)" and click on "(.*?)" button$/ do |arg1, arg2|
  #visit admin_churches_path
  visit send("admin_#{arg1.downcase}_path")
  click_link arg2
end
When /^I visit "(.*?)"$/ do |arg1|
  visit send("admin_#{arg1.downcase}_path")
  #save_and_open_page
end

Then /^the page has a flash$/ do
  page.has_css?('div.flash')
  end

And /^I see an unauthorized message$/ do
  page.has_content?("Error: You are not authorized to perform this action.")
end

When /^I visit a church other than my own$/ do
  church_id = Church.find_by_name("Stockton First UMC").id
  visit admin_church_path(church_id)
  #save_and_open_page
end

