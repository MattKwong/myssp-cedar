ActiveAdmin.register Supporter do
  # The authorization is done using the AdminAbility class
  controller.authorize_resource

  show :title => :last_name
end