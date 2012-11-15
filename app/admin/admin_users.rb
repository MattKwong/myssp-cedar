ActiveAdmin.register AdminUser do
   controller.authorize_resource
   menu :if => proc{ can?(:read, AdminUser) },:parent => "Users and Logs"
    show :title => :name
#    after_create { |admin| admin.send_reset_password_instructions }
  member_action :soft_delete do
    admin_user = AdminUser.find(params[:id])
    admin_user.update_attribute(:deleted_at, Time.current)
    redirect_to :action => :index, :notice => 'User de-activated'
  end
  member_action :reactivate do
    admin_user = AdminUser.find(params[:id])
    admin_user.update_attribute(:deleted_at, nil)
    redirect_to :action => :index, :notice => 'User reactivated'
  end

  scope :active , :default => true
  scope :inactive

  index do
    column :email
    column :name
    column :phone
    column :username
    column :user_role
    column :site
    column :liaison_id
    #column :password
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    column :blocked
    column "Actions" do |admin_user|
      if admin_user.active?
        link_to 'Inactivate', soft_delete_admin_user_path(admin_user)
      else
        link_to 'Reactivate', reactivate_admin_user_path(admin_user)
      end
    end
    default_actions
  end

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :first_name
      f.input :last_name
      #f.input :password
      f.input :phone
      f.input :user_role
      f.input :username, :hint => "Assign name to all site staff - no spaces"
      f.input :site
      f.input :blocked
    end
    f.buttons
    end

  def password_required?
    new_record? ? false : super
  end

end

