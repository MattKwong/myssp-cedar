require 'factory_girl'

FactoryGirl.define do

  factory :admin_user do
    first_name 'Test'
    last_name 'Admin'
    user_role_id UserRole.find_by_name("Admin").id
    email 'user@test.com'
    password 'password'
    confirmed_at Time.now
  end

  factory :liaison_user, class: AdminUser do
    first_name 'Susan'
    last_name 'Liaison'
    user_role_id UserRole.find_by_name("Liaison").id
    liaison_id Liaison.first.id
    email 'liaison@test.com'
    password 'password'
    confirmed_at Time.now
  end

  factory :church do
    active      true
    address1    '100 Easy Street'
    church_type_id ChurchType.find_by_name("Cal Nevada UM Church").id
    city        'Carmichael'
    email1      'church@church.com'
    name        'Carmichael Test Church'
    office_phone '916-123-1001'
    registered  false
    state       'CA'
    zip         '95608'
  end
end