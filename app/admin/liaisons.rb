ActiveAdmin.register Liaison do
  controller.authorize_resource
  menu :if => proc{ can?(:index, Liaison) }, :priority => 5

# This is commented out because these flags weren't properly set when the data was initially input.
# Until we can fit the data, these filters won't work properly
#  scope :scheduled, :default => true
#  scope :unscheduled

  show :title => :name do |liaison|
    panel "Liaison Details" do
      attributes_table_for liaison do
        row("Name") { liaison.name }
        row("Title") { liaison.title }
        row("Liaison to") { liaison.church do |church|
          link_to liaison.church, [:admin, church]
        end }
        row("Liaison Type") { liaison.liaison_type}
        row("Address") { liaison.address1 }
        row("Address 2") {liaison.address2 }
        row("City") {liaison.city}
        row("State") {liaison.state }
        row("Zip code") {liaison.zip }
        row("Last update") { liaison.updated_at }
        row("Has registered group?") { liaison.registered }
        row("Has scheduled group?") { liaison.scheduled }
      end
    end

    panel "Original Request Information" do
      table_for liaison.registrations.current do
        column "Group Name" do |group|
          link_to group.name, admin_registration_path(group.id),
                :title => 'Click to see details of this request.'
          end
        column "Youth", :requested_youth
        column "Counselors", :requested_counselors
        column "Total", :requested_total
        column "Date submitted", :created_at do |reg|
           reg.created_at.in_time_zone("Pacific Time (US & Canada)").strftime("%b %d, %Y %l:%M %p")
        end
        column "Deposit Paid" do |g|
          number_to_currency(g.deposits_paid)
        end
        column "Amount Due" do |g|
          number_to_currency(g.deposits_due - g.deposits_paid)
        end
        column "" do |g|
          if !g.scheduled?
            link_to "Pay by CC", cc_payment_path(:id => g.id, :group_status => 'registration'),
                  :title => "Click to make credit card payment."
          end
        end
        column "" do |g|
          if !g.scheduled?
            link_to "Record Payment", record_payment_path(:group_id => g.id, :group_status => 'registration'),
                :title => "Click to record payment."
          end
        end

      end
    end

    render :partial => 'liaisons/schedule_info'#, :locals => {:liaison => @liaison}

    panel "Current Schedule Group Information" do
      table_for liaison.scheduled_groups.active_program do
        column "Group Name" do |group|
          link_to group.name, myssp_path(group.liaison_id),
          :title => 'Click to go to MySSP page for this liaison.'
        end
        column "Youth", :current_youth
        column "Counselors", :current_counselors
        column "Total", :current_total
        column "Session", :session_id do |session|
          link_to session.session.name, sched_program_session_path(liaison.id,
            :session => session.session.id),:title => "Click to see what other groups are coming to this site at this week."
        end
        column "Site", :session_id do |session|
          session.session.site.name
        end
        column "Period", :session_id do |session|
          session.session.period.name
        end
        column "Start", :session_id do |period|
          period.session.period.start_date.strftime("%m/%d/%y")
        end
        column "End", :session_id do |session|
          session.session.period.end_date.strftime("%m/%d/%y")
        end
      end
    end
    active_admin_comments
  end

  sidebar "Contact Information", :only => :show do
    attributes_table_for liaison.church do
      row("Primary email") { mail_to liaison.email1, liaison.email1, :subject => "SSP", :body => "Dear " }
      row("Second email") { mail_to liaison.email2, liaison.email2, :subject => "SSP", :body => "Dear " }
      row("Cell Phone") { liaison.cell_phone }
      row("Work Phone") { liaison.work_phone }
      row("Home Phone") { liaison.home_phone }
      row("Fax") { liaison.fax }
    end
  end

  sidebar "Church Information", :only => :show do
    attributes_table_for liaison.church do
      row("Primary email") { mail_to liaison.church.email1, liaison.church.email1,
      :subject => "SSP", :body => "Dear " }
      row("Address") {liaison.church.address1}
      row("City") {liaison.church.city}
      row("State") {liaison.church.state}
      row("Zip") {liaison.church.zip}
    end
  end

  sidebar "Liaison Logon Information", :only => :show do
    attributes_table_for liaison do
      row("Status") { liaison.user_created? ? "Created" : (link_to "Create User", create_user_path(liaison.id)) }
    end
  end

  form :title => :name do |f|
    f.inputs "Liaison Details" do
      f.input :first_name
      f.input :last_name
      f.input :church, :include_blank => false, :order => :name
      f.input :title, :hint => "Enter the person's title"
      f.input :liaison_type, :include_blank => false
      f.input :address1
      f.input :address2
      f.input :city
      f.input :state, :input_html => { :maxlength => 2 }
      f.input :zip
      f.input :email1
      f.input :email2
      f.input :cell_phone
      f.input :work_phone
      f.input :home_phone
      f.input :fax
      f.input :scheduled
      f.input :registered
      f.input :user_created, :hint => "Uncheck this only if you need to recreate the liaison's myssp login"
    end
    f.buttons
  end

   index do
     column :name, :sortable => :last_name do |liaison|
       link_to liaison.name, admin_liaison_path(liaison)
     end
     column :church_id, :sortable => false do |church|
       link_to church.church.name, admin_church_path(church.church_id)
     end
     column :email1 do |liaison|
         mail_to liaison.email1, liaison.email1, :subject => "SSP", :body => "Dear #{liaison.first_name},"
     end
     column :liaison_type, :sortable => :liaison_type_id
     column :city, :sortable => :city
     column :state, :sortable => :state
     default_actions
   end
end


