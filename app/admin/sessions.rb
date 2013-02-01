ActiveAdmin.register Session do
  # The authorization is done using the AdminAbility class
  controller.authorize_resource
  menu :if => proc{ can?(:read, Session) }, :parent => "Configuration"

  show :title => :name

  scope :active , :default => true
  scope :inactive

  index do
    column "Session Name", :name
    column "Maximum", :schedule_max
    column "Session Type", :session_type
    column "Program", :program
    column "Waitlist Flag", :waitlist_flag
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
        row("Session Type") {(session.session_type.name)}
        row("Schedule Max") {session.schedule_max }
        row("Waitlist Flag") {session.waitlist_flag }
      end
    end
  end

  form do |f|
    f.inputs "New Session" do
      if f.object.new_record?
        f.input :site, :include_blank => false, :as => :select, :collection => Site.active
        f.input :period, :include_blank => false, :as => :select, :collection => Period.active
        f.input :session_type, :as => :select
        f.input :payment_schedule
        f.input :program, :include_blank => false, :as => :select, :collection => Program.active
        f.input :name
        f.input :schedule_max, :include_blank => false
        f.input :waitlist_flag, :default => true
      else
        f.input :session_type, :as => :select
        f.input :payment_schedule
        f.input :program, :include_blank => false, :as => :select, :collection => Program.active
        f.input :name
        f.input :schedule_max, :include_blank => false
        f.input :waitlist_flag

        end
    f.buttons
    end
  end
end
