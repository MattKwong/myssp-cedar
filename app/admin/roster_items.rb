ActiveAdmin.register RosterItem do
  controller.authorize_resource
  menu :if => proc{ can?(:read, RosterItem) }, :parent => "Groups"
  show :title => :last_name

  scope :youth
  scope :adults, :default => true
  scope :disclosure_received
  scope :disclosure_not_received
  scope :disclosure_incomplete
  scope :covenant_received

  index do
    column "Last Name", :last_name
    column "First Name", :first_name
    column "Group Name", :roster_id do |item|
         link_to item.group_name, myssp_path(item.roster.scheduled_group.liaison_id)
       end
    column "Site", :roster_id do |item| item.roster.scheduled_group.session.site.name end
    column "Week", :roster_id do |item| item.roster.scheduled_group.session.period.name end
    column "Church Name", :roster_id do |item| item.roster.scheduled_group.church.name end
       column "Disclosure Status", :disclosure_status
       column "Male?", :male
       column "Youth?", :youth
     default_actions
  end
end