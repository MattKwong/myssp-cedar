class RegistrationController < ApplicationController
  load_and_authorize_resource
  layout 'admin_layout'
  require 'erb'
  #
  #def new
  #  @page_title = "Register a New Summer Group"
  #  @liaison = Liaison.find(params[:id])
  #  @registration = Registration.new
  #  @site_selection = ''
  #  @available_sites = Site.all
  #  @period_selection = ''
  #  @periods_available = Period.all
  #end

  def new
    puts (can? :create, Registration)
    @page_title = "Register a New Group"
    @liaison = Liaison.find(params[:liaison_id])
    @registration = Registration.new

    @site_selection = ''
    @period_selection = ''
  end

  def index
    @title = "Manage Groups"
  end

  def edit              #prior to /:id/edit view
    @registration = Registration.find(params[:id])
    @page_title = "Edit Your Registration"
  end

  def update

    new_requested_total = (params[:registration][:requested_youth]).to_i + (params[:registration][:requested_counselors]).to_i
    increase = new_requested_total - @registration.requested_total
    if new_requested_total > @registration.limit
      flash[:error] = "Your registration total exceeds the maximum of #{@registration.limit}."
      @page_title = "Edit Your Registration"
      render "edit"
    else
      if @registration.update_attributes(params[:registration])
        log_activity("Registration Update", "#{@registration.name}: Total changed by: #{increase}")
        UserMailer.registration_change_confirmation(@registration, params).deliver
        flash[:notice] = "Your registration has been successfully changed."
        redirect_to show_registration_path(@registration, :increase => increase)
      else
        @page_title = "Edit Your Registration"
        render "edit"
      end
    end
  end

  def show
    @registration = Registration.find(params[:id])
    @page_title = "Successful Registration Update"
    @increase_message = ''
    if params[:increase].to_i > 0
      @increase_message = "Note: Since you have increased your numbers, you may need to pay additional deposits to SSP. When you return to your Main Page,
check amount listed in the Amount Due column. This can be paid either by check or by credit card."
    end
    render "show"
   end

  def schedule
    @title = "Schedule a Group"
    @page_title = "Schedule a Group"
    @registration = Registration.find(params[:id])
    authorize! :update, @registration
    @church = Church.find(@registration.church_id)
    @liaison = Liaison.find(@registration.liaison_id)
    @session = Session.find(@registration.request1)
    @site = Site.find(@session.site_id)
    @period = Period.find(@session.period_id)
    @requests = Array[@registration.request1, @registration.request2, @registration.request3,
        @registration.request4, @registration.request5, @registration.request6,
        @registration.request7, @registration.request8, @registration.request9,
        @registration.request10]

    first_nil = @requests.index(nil)
    if first_nil.nil?
      first_nil = 10
    end

    first_zero = @requests.index(0)
    if first_zero.nil?
      first_zero = 10
    end
    @requests_size = (first_nil < first_zero ? first_nil : first_zero)
    @requests.slice!(@requests_size, @requests.size - @requests_size)
    @sessions = Session.all
    @selection = 0
    @alt_sessions = Session.active.by_type(@registration.group_type_id).map  { |s| [s.name, s.id]}
    @requests.each { |i| @alt_sessions.delete_if { |j| j[1] == i }}
  end

  def alt_schedule
    @priority = params[:priority]
    @session_id = params[:id]
    @registration = params[:reg]
    redirect_to scheduled_groups_schedule_path(:priority => @priority, :reg => @registration, :id => @session_id)
  end

  def show_schedule
    @schedule = Session.session_matrices(params[:type])
    @page_title = "#{params[:type].titleize} Groups By Site and Week"
  end


  def get_limit_info
    #Let Summer senior high be the default in the event that an invalid value is passed
    jh_max = 20
    sh_max = 30
    session = Session.find_by_site_id_and_period_id(params[:site], params[:week])

    if session.junior_high?
      session_max = session.available < jh_max ? session.available : jh_max
    else
      session_max = session.available < sh_max ? session.available : sh_max
    end

    if session.summer_domestic?
      @limit_text = "Registering for #{session.name}. You may register up to #{session_max} persons in total. We suggest a ratio of 1 counselor for every 4 junior high youth and 5 senior high youth."
      @limit = session_max
    else
      @limit_text = "Registering for #{session.name}. You may register up to #{session.available} persons in total. We recommend a ratio of about 1 adult for every 4 or 5 youth."
      @limit = session.available
    end

    @group_type_name =  session.session_type.name
    @session_name =  session.name
    @waitlist_flag = session.waitlist_flag
    render :partial => "limit_info"
  end

  def terms_and_conditions
    session = Session.find_by_site_id_and_period_id(params[:site], params[:week])
    if session.payment_schedule.second_payment_date
      @second_pay_line_text = "3. Your second payment is due on #{session.payment_schedule.second_payment_date.strftime("%m/%d/%y")}."
      @final_pay_line_text = "4. Your final payment is due on #{session.payment_schedule.final_payment_date.strftime("%m/%d/%y")}."
    else
      @second_pay_line_text = "3. You do not have a second payment due."
      @final_pay_line_text = "4. Your final payment is due when you arrive at your session on #{session.session_start_date.strftime("%m/%d/%y")}."
    end
    render :partial => "terms_and_conditions"
  end

  def get_sites_for_group_type
    if params[:value] == SessionType.find_by_name("Junior High").id.to_s
       @list_of_sites = Session.sites_with_avail_for_type(params[:value])
    else
       @list_of_sites = Session.sites_with_avail_for_type_senior
    end
    render :partial => "site_selector"
  end

  def get_sites_for_other_groups
    @list_of_sites = Session.sites_with_avail_for_type(params[:type])
    #@list_of_sites = Session.sites_with_avail_for_other
    render :partial => "site_selector"
  end

  def check_for_sessions_for_type
    if session_type = SessionType.find_by_name(params[:type]).id
      @session_count = Session.active.find_all_by_session_type_id(session_type).count
      @available_session_count = Session.sessions_with_avail_for_type(params[:type]).count
    else
      @session_count = @available_session_count = 0
    end
    render :partial => "session_count"
  end

  #def get_sites_for_group_type
  #
  # This is the pre-scheduling version of this routine which does not check for availability.
  #
  #  #As above, let Summer senior high be the default in the event that an invalid value is passed
  #  if params[:value] == SessionType.find_by_name("Summer Junior High").id.to_s
  #     @list_of_sites = Session.sites_for_group_type(params[:value])
  #  else
  #     @list_of_sites = Session.sites_for_group_type_senior
  #  end
  #
  #  render :partial => "site_selector"
  #end

  def get_alt_sites_for_group_type
    #get the session id from current_site and current_week params

    current_session = Session.find_by_site_id_and_period_id(params[:current_site], params[:current_week])
    logger.debug current_session.inspect
    @session_choices = params[:session_choices].split('/')
    @session_choices[params[:number_of_choices].to_i] = current_session.id.to_s

    @session_choices_names = params[:session_choices_names].split('/')
    @session_choices_names[params[:number_of_choices].to_i] = current_session.name
    @session_count = (params[:number_of_choices].to_i)
    #As above, let Summer senior high be the default in the event that an invalid value is passed
    #logger.debug @session_choices
    #logger.debug @session_choices_names.inspect

    if params[:value] == SessionType.find_by_name("Junior High").id.to_s
       @list_of_sites = Session.alt_sites_for_group_type(params[:value], @session_choices)
    else
       @list_of_sites = Session.sites_for_group_type_senior
    end
    #logger.debug @list_of_sites.inspect

    render :partial => "alt_site_selector"
  end

  #def get_sessions_for_type_and_site
  #  #
  #  #This is the pre-scheduling version of the routine.
  #  #
  #  @list_of_sessions = Array.new
  #  if SessionType.find(params[:value]).name == "Summer Junior High"
  #    sessions = Session.junior_high.active.find_all_by_site_id(params[:site])
  #  else
  #    sessions = Session.senior_high.active.find_all_by_site_id(params[:site])
  #  end
  #
  #  sessions.each { |s| @list_of_sessions << s.period}
  #  @site_name = Site.find(params[:site]).name
  #  render :partial => "session_selector"
  #end

  def get_sessions_for_type_and_site

    @list_of_sessions = Array.new
    if SessionType.find(params[:value]).name == "Junior High"
      sessions = Session.junior_high.active.find_all_by_site_id(params[:site])
    else
      sessions = Session.senior_high.active.find_all_by_site_id(params[:site])
    end

    sessions.each do |s|
      if s.available > 0
        @list_of_sessions << s.period
      end
    end

    @site_name = Site.find(params[:site]).name
    render :partial => "session_selector"
  end

  def get_other_sessions_for_site
    @list_of_sessions = Array.new
    sessions = Session.sessions_with_avail_for_type_and_site_id(params[:type], params[:site])
    sessions.each do |s|
      if s.available > 0
        @list_of_sessions << s.period
      end
    end

    @site_name = Site.find(params[:site]).name
    render :partial => "session_selector"
  end

  def get_session_name
    session = Session.find_by_site_id_and_period_id(params[:site], params[:session])
    if session.waitlist_flag?
      @availability_text = "Registration is currently on hold for this session because there is a waitlist. Please contact the SSP office at 916-488-6441 to add your name to the waitlist and get more information."
    else
      @availability_text = "#{session.name} has #{session.available.to_i} spots available."
    end
    @waitlist_flag = session.waitlist_flag

    render :partial => "session_name"
  end

  def get_alt_sessions_for_type_site
    @list_of_sessions = Array.new
    sessions = Session.by_session_type_and_site(params[:value],params[:site] )
    if SessionType.find(params[:value]).name == "Summer Junior High"
      sessions = Session.junior_high.active.find_all_by_site_id(params[:site])
    else
      sessions = Session.senior_high.active.find_all_by_site_id(params[:site])
    end
    #Eliminate already selected sessions
    session_choices = params[:session_choices].split(',')
    logger.debug session_choices
    sessions.delete_if {|s| session_choices.include?(s.id.to_s)}
    sessions.each { |s| @list_of_sessions << s.period}
    @site_name = Site.find(params[:site]).name
    render :partial => "alt_session_selector"
  end

  def save_registration_data
    @registration = Registration.new
    liaison = Liaison.find(params[:liaison_id])
    @registration.church_id = liaison.church_id
    @registration.comments = params[:comments]
    #@registration.group_type_id = params[:group_type]
    @registration.liaison_id = liaison.id
    session = Session.find_by_site_id_and_period_id(params[:site_choice], params[:week_choice])
    @registration.name = "#{liaison.church.name} #{session.name}"
    @registration.group_type_id = session.session_type_id
    @registration.request1 = session.id
    @registration.requested_counselors = params[:requested_adults].to_i
    @registration.requested_youth = params[:requested_youth].to_i
    @registration.requested_total = params[:requested_youth].to_i + params[:requested_adults].to_i
    @registration.scheduled = false
    if @registration.save
      @registration_saved = true
      @registration_id = @registration.id
      @deposit_amount = @registration.requested_total * 50
      @processing_charge = (@deposit_amount * 0.029)
      @to_be_charged = @deposit_amount + @processing_charge
      set_registered_flag
      log_activity("Registration Created", "Group Type: #{@registration.type } Total requested: #{@registration.requested_total}")
      ScheduledGroup.schedule(@registration_id, session.id, 0)
      @message = "Save of registration request and scheduled group was successful."
      @group_type = session.program.program_type.name
    else
      @registration_saved = false
      @message = "A problem has occurred saving this registration. Please call the SSP office if you continue to have problems."
    end
    render :partial => 'save_registration_data'
  end

  #def save_registration_data
  #
  # This is the pre-scheduling version of this routine
  #
  #  @registration = Registration.new
  #  session_choices = params[:session_choices].split(',')
  #  liaison = Liaison.find(params[:liaison_id])
  #  logger.debug liaison.inspect
  #  logger.debug session_choices.inspect
  #  @registration.church_id = liaison.church_id
  #  @registration.comments = params[:comments]
  #  @registration.comments = params[:comments]
  #  @registration.group_type_id = params[:group_type]
  #  @registration.liaison_id = liaison.id
  #  @registration.name = "#{liaison.church.name} #{SessionType.find(params[:group_type]).name}"
  #
  #  @registration.request1 = session_choices[0]
  #  @registration.request2 = session_choices[1]
  #  @registration.request3 = session_choices[2]
  #  @registration.request4 = session_choices[3]
  #  @registration.request5 = session_choices[4]
  #  @registration.request6 = session_choices[5]
  #  @registration.request7 = session_choices[6]
  #  @registration.request8 = session_choices[7]
  #  @registration.request9 = session_choices[8]
  #  @registration.request10 = session_choices[9]
  #  @registration.requested_counselors = params[:requested_adults].to_i
  #  @registration.requested_youth = params[:requested_youth].to_i
  #  @registration.requested_total = params[:requested_youth].to_i + params[:requested_adults].to_i
  #  @registration.scheduled = false
  #  if @registration.save
  #    @registration_saved = true
  #    @message = "Save of registration request successful."
  #    @registration_id = @registration.id
  #    @deposit_amount = @registration.requested_total * 50
  #    @processing_charge = (@deposit_amount * 0.029)
  #    @to_be_charged = @deposit_amount + @processing_charge
  #    set_registered_flag
  #    log_activity("Registration Created", "Group Type: #{@registration.type } Total requested: #{@registration.requested_total}")
  #  else
  #    @registration_saved = false
  #    @message = "A problem has occurred saving this registration. Please call the SSP office if you continue to have problems."
  #  end
  #
  #  render :partial => 'save_registration_data'
  #
  #end

  def set_registered_flag
    liaison = Liaison.find(@registration.liaison_id)
    liaison.registered = true
    liaison.scheduled = true
    liaison.save
    church = Church.find(@registration.church_id)
    church.registered = true
    church.active = true
    church.save
  end

  def pay_by_check
    @registration = Registration.find(params[:reg_id])
    @registration.amount_paid = params[:amount_paid]
    @registration.payment_notes = params[:payment_tracking_number]
    @registration.save
    #Create the confirmation email
    UserMailer.registration_confirmation(@registration, params).deliver
    render :partial => "final_confirmation"
  end

  def process_cc_dep_payment
    token = params[:payment_tracking_number]
    @registration = Registration.find(params[:reg_id])

    begin
      to_be_charged = (100 * params[:amount_paid].to_f).to_i
      logger.debug to_be_charged
      logger.debug token
      charge = Stripe::Charge.create(
        :amount=> to_be_charged,
        :currency=>"usd",
        :card => token,
        :description => @registration.name)
    rescue Stripe::InvalidRequestError => e
      @payment_error_message = "There has been a problem processing your credit card."
      logger.debug e.message
    rescue Stripe::CardError => e
      @payment_error_message = e.message
      logger.debug e.message
    end

    if e
      logger.debug e.inspect
      render :partial => 'payment_gateway'
    else
      #Needs to find and save the registration instance with the payment information
      @registration = Registration.find(params[:reg_id])
      @registration.amount_paid = params[:amount_paid]
      @registration.payment_notes = params[:payment_tracking_number]
      @registration.save
      scheduled_group_id = ScheduledGroup.find_by_registration_id(params[:reg_id]).id

      @deposit_amount = @registration.requested_total * 50
      p = Payment.record_deposit(@registration.id, scheduled_group_id, @deposit_amount, params[:processing_charge], "cc", @registration.payment_notes)
      #Create the confirmation email
      if p
        log_activity("CC Payment", "Group: #{@registration.name} Fee amount: $#{sprintf('%.2f', params[:deposit_amount].to_f)} Processing chg: $#{sprintf('%.2f', params[:processing_charge].to_f)}")
        UserMailer.registration_confirmation(@registration, params).deliver
        render :partial => "final_confirmation"
      else
        @payment_error_message = "Unsuccessful save of payment record - please contact the SSP office."
        render :partial => 'payment_gateway'
      end
    end
  end

  def finish_up
    render myssp_path(current_admin_user.liaison_id)
  end

  def request_matrix
    @matrix = Session.session_matrices("Summer Domestic")
    @senior_high_limit = 60
    render :partial => 'request_matrix', :reg_or_sched => "registered"
  end

  def availability_matrix
    jh_default = 50
    sh_default = 65
    @matrices = Session.session_matrices("Summer Domestic", sh_default, jh_default)
    render :partial => 'availability_matrix'
  end

  def other_availability_matrix
    jh_default = 50
    sh_default = 65
    @matrices = Session.active.session_matrices("Other", sh_default, jh_default)
    render :partial => 'other_availability_matrix'
  end

  private
  def log_activity(activity_type, activity_details)
    a = Activity.new
    a.activity_date = Time.now
    a.activity_type = activity_type
    a.activity_details = activity_details
    a.user_id = current_admin_user.id
    a.user_name = current_admin_user.name
    a.user_role = current_admin_user.user_role
    unless a.save!
      flash[:error] = "Unknown problem occurred logging a transaction."
    end
  end
 end

