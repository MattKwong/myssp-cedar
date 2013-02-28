class ApplicationController < ActionController::Base
  protect_from_forgery :only => [:create, :update]
  #load_and_authorize_resource
  add_breadcrumb "Home", '/'
  layout 'admin_layout'
  rescue_from Timeout::Error, :with => :rescue_from_timeout
  before_filter :check_for_non_admin_lock_out , :except => [:create, :destroy]
  include ReCaptcha::AppHelper

  def auto_schedule
    @page_title = "Auto Schedule Groups"
    #@schedule_object = {:group_type => '2', :schedule_method => 'largest_first', :target => 65, :max => 69}
    render 'auto_schedule'
  end

  def run_schedule
    @page_title = "Schedule Results"
    @method = params[:method]
    @group_type = params[:group_type]
    @target = params[:target].to_i
    @max = params[:max].to_i
    if params[:target] == '' || params[:max] == ''
      flash[:error] = "You must enter target and max values."
      @page_title = "Auto Schedule Groups"
      render 'auto_schedule'
    else
      if params[:method] == "Largest First"
        if params[:group_type] == "Senior High"
          SessionType.senior_high.first.schedule_largest_first(params[:target].to_i, params[:max].to_i)
          @results = SessionType.senior_high.first.report_scheduling_results(@target)
        else
          SessionType.junior_high.first.schedule_largest_first(params[:target].to_i, params[:max].to_i)
          @results = SessionType.junior_high.first.report_scheduling_results(@target)
        end
      else
        if params[:group_type] == "Senior High"
          SessionType.senior_high.first.schedule_smallest_first(params[:target].to_i, params[:max].to_i)
          @results = SessionType.senior_high.first.report_scheduling_results(@target)
        else
          SessionType.junior_high.first.schedule_smallest_first(params[:target].to_i, params[:max].to_i)
          @results = SessionType.junior_high.first.report_scheduling_results(@target)
        end
      end
    end
  end

  def rollback_senior_schedule
    SessionType.senior_high.first.rollback
    flash[:notice] = "All senior high groups have been unscheduled."
    redirect_to auto_schedule_path
  end

  def rollback_junior_schedule
    SessionType.junior_high.first.rollback
    flash[:notice] = "All junior high groups have been unscheduled."
    redirect_to auto_schedule_path
  end

  def update_requests
    SessionType.junior_high.first.update_session_requests
    SessionType.senior_high.first.update_session_requests
    flash[:notice] = "Session request values have been updated."
    redirect_to auto_schedule_path
  end

  def send_emails
    number = SessionType.junior_high.first.send_confirmation_emails
    flash[:notice] = "#{number} schedule confirmation emails have been sent to Junior High groups."

    number = SessionType.senior_high.first.send_confirmation_emails
    flash[:notice] += "  #{number} schedule confirmation emails have been sent to Senior High groups."
    redirect_to auto_schedule_path
  end

  def report_results
    @jh_results = SessionType.junior_high.first.report_scheduling_results
    @sh_results = SessionType.senior_high.first.report_scheduling_results
  end

  def lock_out_users
    AdminUser.non_admin.each do |user|
      user.update_attributes(:blocked => true)
    end
    flash[:notice] = "Non-admin users have been blocked."
    redirect_to :root
  end

  def unlock_users
    AdminUser.non_admin.each do |user|
      user.update_attributes(:blocked => false)
    end
    flash[:notice] = "Non-admin users have been unblocked."
    redirect_to :root
  end

  def update_flags
    Church.all.each do |church|
      church.update_attribute(:registered, false)
    end

    Liaison.all.each do |liaison|
      liaison.update_attributes(:registered => false, :scheduled => false)
    end

    Registration.current_unscheduled.each do |registration|
      church = Church.find(registration.church_id)
      church.update_attribute(:registered, true)
      liaison = Liaison.find(registration.liaison_id)
      liaison.update_attribute(:registered, true)
    end

    flash[:notice] = "Church and liaison scheduled and registered flags have been updated."
    redirect_to :root
  end

  protected

  def check_for_non_admin_lock_out
    if signed_in?
      if current_admin_user.liaison? || current_admin_user.field_staff?
        if current_admin_user.blocked?
          @page_title = "System Temporarily Unavailable"
          flash[:notice] = "You are unable to use the MySSP system at this time."
          render blocked_user_path
        end
      end
    end
  end

  def after_sign_in_path_for(resource) #this overrides the default method in the devise library

   program_user = ProgramUser.find_by_user_id(resource.id)

   if resource.liaison?
     liaison = Liaison.find(resource.liaison_id)
     church = Church.find(liaison.church_id)
     if church.nil? #the liaison is unassigned to a church, so he/she can't do anything
       log_activity(Time.now, "Invalid Login", "Unassigned to church - logged off", resource.id, resource.name, resource.user_role)     #redirect_to :back
       destroy_admin_user_session_path #log out
     else
       log_activity(Time.now, "Liaison Login", "Logged on to system", resource.id, resource.name, resource.user_role)
       return myssp_path(liaison.id)
     end
   else
   if resource.admin?
     log_activity(Time.now, "Admin Login", "Logged on to system", resource.id, resource.name, resource.user_role)
     return '/admin'
   else
     if resource.construction_admin?
       log_activity(Time.now, "Construction Admin Login", "Logged on to system", resource.id, resource.name, resource.user_role)
       return ops_pages_show_path
     else
       if resource.food_admin?
         log_activity(Time.now, "Food Admin Login", "Logged on to system", resource.id, resource.name, resource.user_role)
         return ops_pages_show_path
       else
         if resource.staff?
           program_user = ProgramUser.find_by_user_id(resource.id)
           log_activity(Time.now, "#{program_user.job.job_type.name} Login", "Logged on to system", resource.id, resource.name, resource.user_role)
             return program_path(program_user.program_id)
         end
       end
     end
   end
 end

 end

  def current_ability
      @current_ability ||= Ability.new(current_admin_user)
  end

  def log_activity(activity_date, activity_type, activity_details, user_id, user_name, user_role)

    a = Activity.new
    a.activity_date = activity_date
    a.activity_type = activity_type
    a.activity_details = activity_details
    a.user_id = user_id
    a.user_name = user_name
    a.user_role = user_role
    unless a.save!
      flash[:error] = "Unknown problem occurred logging a transaction."
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    resource ||= @current_admin_user
    flash[:error] = "Error: You are not authorized to perform this action."
    if resource.liaison?
      redirect_to myssp_path(resource.liaison_id)
    else if resource.admin?
      redirect_to '/admin'
         end
    end
  end

  private
  def rescue_from_timeout
    log_activity(Time.now, "Error", "System timeout error", @current_admin_user.id, current_admin_user.name, "")
    redirect_to timeout_error_path
  end
end
