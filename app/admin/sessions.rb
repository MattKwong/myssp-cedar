ActiveAdmin.register Session do
  # The authorization is done using the AdminAbility class
  controller.authorize_resource
  menu :if => proc{ can?(:read, Session) }, :parent => "Configuration"

  show :title => :name

  scope :active , :default => true
  #scope :all,   scope :not_current, where('created_at < ?', '2012-09-01'.to_datetime)

  index do
    column "Session Name", :name
    column "Maximum", :schedule_max
    column "Accepts Groups" do |session|
      (session.session_types.map{ |type| type.name}).join(', ')
    end
    default_actions
  end

  show :title => :name do
    panel "Session Details " do
      attributes_table_for session do
        row("Session Name") {session.name}
        row("Site") {session.site.name}
        row("Program") {session.program.name}
        row("Start Date") {session.period.start_date}
        row("End Date") {session.period.end_date}
        row("Session Types") {(session.session_types.map{ |type| type.name}).join(', ')}
        row("Schedule Max") {session.schedule_max }
      end
    end
  end

  form do |f|
    f.inputs "New Session" do
      if f.object.new_record?
        f.input :site, :include_blank => false, :as => :select, :collection => Site.active
        f.input :period, :include_blank => false, :as => :select, :collection => Period.active
        f.input :session_types, :as => :check_boxes
        f.input :payment_schedule
        f.input :program, :include_blank => false, :as => :select, :collection => Program.active
        f.input :name
        f.input :schedule_max, :include_blank => false
      else
        f.input :session_types, :as => :check_boxes
        f.input :payment_schedule
        f.input :program, :include_blank => false, :as => :select, :collection => Program.active
        f.input :name
        f.input :schedule_max, :include_blank => false
        end
    f.buttons
    end
  end
end
