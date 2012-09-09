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