require 'factory_girl_rails'

FactoryGirl.define do

  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :username do |n|
    "SSPuser#{n}"
  end

  sequence :phone do |n|
    "#{n}#{n}#{n}#{n}#{n}#{n}#{n}#{n}#{n}#{n}"
  end

  sequence :inc_number do |n|
    "#{n}"
  end
#end

#Matt's factory
#FactoryGirl.define do
  factory :admin_user do
    first_name "John"
    last_name "Doe"
    email FactoryGirl.generate :email
    confirmation_sent_at { 2.day.ago }
    confirmed_at { 1.day.ago }
    user_role_id { UserRole.find_by_name("Admin").id }
    username FactoryGirl.generate :username
    password "foobar"
    password_confirmation "foobar"
    phone FactoryGirl.generate :phone
    #liaison_id FactoryGirl.generate :inc_number
  end

  factory :user_role do
    id { 1 }
    name  "Admin"
  end


  # Factories from Rick's Latest repo
  #factory :admin_user do
  #  first_name 'Test'
  #  last_name 'Admin'
  #  #user_role_id UserRole.find_by_name("Admin").id
  #  email 'adminuser@factory.com'
  #  password 'password'
  #  confirmed_at Time.now
  #end
  #
  #factory :liaison_user, class: AdminUser do
  #  first_name 'Susan'
  #  last_name 'Liaison'
  #  #user_role_id UserRole.find_by_name("Liaison").id
  #  liaison_id Liaison.first.id
  #  email 'adminuserliaison@factory.com'
  #  password 'password'
  #  confirmed_at Time.now
  #end
  #
  #factory :church do
  #  active      true
  #  address1    '100 Easy Street'
  #  church_type_id ChurchType.find_by_name("Cal Nevada UM Church").id
  #  city        'Carmichael'
  #  email1      'church1@factory.com'
  #  name        'Carmichael Test Church'
  #  office_phone '916-123-1001'
  #  registered  false
  #  state       'CA'
  #  zip         '95608'
  #end
  #
  #factory :liaison do
  #  address1        '100 Easy Street'
  #  cell_phone      '916-123-1001'
  #  church_id       0
  #  home_phone      '916-123-1002'
  #  work_phone      '916-123-1003'
  #  fax             ''
  #  city            'Carmichael'
  #  email1          'liaison1@factory.com'
  #  first_name      'Test'
  #  last_name       'FactoryLiaison'
  #  liaison_type_id LiaisonType.find_by_name("Both Junior and Senior High").id
  #  registered      false
  #  scheduled       false
  #  state           'CA'
  #  title           'Pastor'
  #  zip             '95608'
  #end
  #
  #factory :registration do
  #  group_type_id     SessionType.find_by_name('Summer Senior High').id
  #  liaison_id        Liaison.last.id
  #  church_id         Liaison.last.church_id
  #  amount_due        '1000.00'
  #  amount_paid       '200.0'
  #  name              'Carmichael Test Senior High'
  #  payment_method    'Check'
  #  request1          Session.find_by_name('Test Site 1 Week 1').id
  #  requested_counselors  2
  #  requested_youth       12
  #  requested_total       14
  #  scheduled             false
  #end
  #
  #factory :scheduled_group do
  #  church_id             1
  #  current_counselors    1
  #  current_total         1
  #  current_youth         1
  #  group_type_id         1
  #  liaison_id            1
  #  name                  "Factory Scheduled Group"
  #  registration_id       1
  #  scheduled_priority    1
  #  session_id            1
  #  second_payment_total  100
  #  roster_id             1
  #end
end