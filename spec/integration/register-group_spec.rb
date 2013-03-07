require 'spec_helper'

feature "Register a group" do

  scenario "access sign in page by direct link" do
    visit '/admin_users/sign_in'
  end

end