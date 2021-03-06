ActiveAdmin.register Registration do
  # The authorization is done using the AdminAbility class
  controller.authorize_resource
  menu :if => proc{ can?(:read, Registration) }, :label => "Requests", :parent => "Groups"

  scope :unscheduled
  scope :current
  scope :current_unscheduled, :default => true

 index :title => "Registration Requests" do
    column "Year" do |r|
      r.created_at < "09-01-2012".to_datetime ? "2012" : "2013"
    end
    column :name do |r|
      link_to r.name, schedule_request_path(:id => r.id),
        :title => "Click to schedule this group"
    end
    column :liaison_id do |liaison|
      link_to liaison.liaison.name, admin_liaison_path(liaison.liaison_id)
    end
    column :church_id do |reg|
      link_to reg.liaison.church.name, admin_church_path(reg.liaison.church_id)
    end
    column :group_type_id, :sortable => :group_type_id do |group_type|
      group_type.session_type.name
    end
    column "Youth", :requested_youth
    column "Counselors", :requested_counselors
    column "Total", :requested_total
    column :request1, :sortable => :request1 do |reg|
      if reg.request1
        Session.find(reg.request1).short_name
      end
    end
    column :request2, :sortable => :request2 do |reg|
      if reg.request2.is_a?(Numeric) && reg.request2 > 0
        Session.find(reg.request2).short_name
      end
    end
    column :request3, :sortable => :request3 do |reg|
      if reg.request3.is_a?(Numeric) && reg.request3 > 0
        Session.find(reg.request3).short_name
      end
    end
    column :request4, :sortable => :request4 do |reg|
      if reg.request4.is_a?(Numeric) && reg.request4 > 0
        Session.find(reg.request4).short_name
      end
    end
    default_actions
 end

   show :title => :name do
    panel "Request Details " do
      attributes_table_for registration do
        row("Registration Name") {registration.name}
        row("Registration Type") {registration.session_type.name}
        row("Liaison") {registration.liaison}
        row("Request1") {if registration.request1 then Session.find(registration.request1).name end }
        row("Request2") {if registration.request2 then Session.find(registration.request2).name end }
        row("Request3") {if registration.request3 then Session.find(registration.request3).name end }
        row("Request4") {if registration.request4 then Session.find(registration.request4).name end }
        row("Request5") {if registration.request5 then Session.find(registration.request5).name end }
        row("Request6") {if registration.request6 then Session.find(registration.request6).name end }
        row("Request7") {if registration.request7 then Session.find(registration.request7).name end }
        row("Request8") {if registration.request8 then Session.find(registration.request8).name end }
        row("Request9") {if registration.request9 then Session.find(registration.request9).name end }
        row("Request10") {if registration.request10 then Session.find(registration.request10).name end }
        row("Counselors") {registration.requested_counselors}
        row("Youth") {registration.requested_youth}
        row("Total") {registration.requested_total}
        row("Scheduled") {registration.scheduled}
        row("Amount paid") {registration.amount_paid}
        row("Amount due") {registration.amount_due}
        row("Payment method") {registration.payment_method}
        row("Payment notes") {registration.payment_notes}
        row("Comments") {registration.comments}
        row("Created at") {registration.created_at}
        row("Updated at") {registration.updated_at}
      end
    end
   end
  form :title => :name do |f|
    f.inputs "Edit Request Details" do
      f.input :name
      f.input :requested_youth
      f.input :requested_counselors
      f.input :comments
      f.input :request1, :as => :select, :collection => Session.active.by_type(f.object.group_type_id), :include_blank => false
      f.input :request2, :as => :select, :collection => Session.active.by_type(f.object.group_type_id), :include_blank => true
      f.input :request3, :as => :select, :collection => Session.active.by_type(f.object.group_type_id), :include_blank => true
      f.input :request4, :as => :select, :collection => Session.active.by_type(f.object.group_type_id), :include_blank => true
      f.input :request5, :as => :select, :collection => Session.active.by_type(f.object.group_type_id), :include_blank => true
      f.input :request6, :as => :select, :collection => Session.active.by_type(f.object.group_type_id), :include_blank => true
      f.input :request7, :as => :select, :collection => Session.active.by_type(f.object.group_type_id), :include_blank => true
      f.input :request8, :as => :select, :collection => Session.active.by_type(f.object.group_type_id), :include_blank => true
      f.input :request9, :as => :select, :collection => Session.active.by_type(f.object.group_type_id), :include_blank => true
      f.input :request10, :as => :select, :collection => Session.active.by_type(f.object.group_type_id), :include_blank => true
   end
    f.buttons
  end

  filter :request1, :as => :select, :collection => proc { Session.active.all }
  filter :request2, :as => :select, :collection => proc { Session.active.all }
  filter :request3, :as => :select, :collection => proc { Session.active.all }
  filter :name
  filter :church
  filter :liaison

  csv do
    column :name
    column :email1 do |r|
      r.liaison.email1
    end
    column :liaison_name do |r|
      r.liaison.name
    end
    column :church_name do |r|
      r.liaison.church.name
    end
    column :group_type do |r|
      r.session_type.name
    end

    column :requested_youth
    column :requested_counselors
    column :requested_total
    column :request1 do |reg|
      if reg.request1
        Session.find(reg.request1).short_name
      end
    end
    column :request2 do |reg|
      if reg.request2
        Session.find(reg.request2).short_name
      end
    end
    column :request3 do |reg|
      if reg.request3
        Session.find(reg.request3).short_name
      end
    end
    column :request4 do |reg|
      if reg.request4
        Session.find(reg.request4).short_name
      end
    end
    column :deposits_paid
    column :amount_due do |reg|
      number_to_currency (reg.deposits_due - reg.deposits_paid)
    end
    column :comments
    column :created_at
    column :updated_at

  end

end
