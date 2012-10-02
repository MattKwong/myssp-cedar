And /^I see the "(.*?)" current section$/ do |arg1|
  find(".process_step").should have_content(arg1)
end

Given /^a liaison in Step (\d+)$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I select a group type and click "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I input youth and counselor values$/ do
  pending # express the regexp above with the code you wish you had
end


And /^I see the registration name$/ do
  find("#registration_info").should have_content(Registration.find_all_by_liaison_id(@liaison1.id).first.name)
end

And /^I see the scheduled group name$/ do
  find("#scheduled_group_info").should have_content(ScheduledGroup.find_all_by_liaison_id(@liaison1.id).first.name)
end
And /^I do not see the registration name$/ do
  find("#registration_info").should have_content('')
end

And /^I do not see the scheduled group name$/ do
  find("#scheduled_group_info").should_not have_content(ScheduledGroup.find_all_by_liaison_id(@liaison1.id).first.name)
end
