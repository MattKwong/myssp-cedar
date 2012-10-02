ActiveAdmin.register Period do
  # The authorization is done using the AdminAbility class
  controller.authorize_resource
  menu :if => proc{ can?(:read, Period) }, :parent => "Configuration"
  scope :active

 show :title => :name

 form do |f|
    f.inputs "Period Details: #{:name}" do
      f.input :name
      f.input :start_date, :start_year => 2012, :value => 21020601, :required => true
      f.input :end_date, :start_year => 2012, :required => true
      f.input :active, :required =>  true
      f.input :summer_domestic, :required =>  true
    end
    f.buttons
  end
end