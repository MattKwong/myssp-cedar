class RegistrationController < ApplicationController
  load_and_authorize_resource
  layout 'admin_layout'
  require 'erb'

  def new
    @page_title = "Register a New Group"
    @liaison = Liaison.find(params[:id])
    @registration = Registration.new
    @site_selection = ''
    @available_sites = Site.all
    @period_selection = ''
    @periods_available = Period.all
  end

  def create
    render 'new'
  end

  def index
    @title = "Manage Groups"
  end

  #def register                #prior to display of register view
  #  @registration = Registration.new
  #  authorize! :create, @registration
  #  @liaisons = Liaison.all.map { |l| [l.name, l.id ]}
  #  @group_types = SessionType.all.map { |s| [s.name, s.id ]}
  #  @title = "Register A Group"
  #  @page_title = "Register A Group"
  #  render "register"
  #end

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

  def process_payment   #prior to rendering process_payment step 3
    @registration = Registration.find(params[:id])
    authorize! :update, @registration
    @liaison = Liaison.find(@registration.liaison_id)
    @church = Church.find(@liaison.church_id)
    @group_type = SessionType.find(@registration.group_type_id)
    @session = Session.find(@registration.request1)
    @payment_schedule = PaymentSchedule.find(@session.payment_schedule_id)
    @registration.amount_due= @payment_schedule.deposit * (@registration.requested_counselors + @registration.requested_youth)
    @payment_types = 'Check', 'Credit Card', 'Cash'
    @title = "Registration Step 3"
    @page_title = "Register A Group: Step 3"
  end

  def successful
    @title = "Completed Registration"
    @page_title = "Register A Group: Complete"
    @registration = Registration.find(params[:id])
    @church = Church.find(@registration.church_id)
    @liaison = Liaison.find(@registration.liaison_id)
    @session = Session.find(@registration.request1)
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
    build_schedule(params[:reg_or_sched], params[:type])
  end


  def get_limit_info
    #Let Summer senior high be the default in the event that an invalid value is passed
    if params[:value] == SessionType.find_by_name("Summer Junior High").id.to_s
      @limit_text = 'You may register up to 20 persons in total. We suggest a ratio of 1 counselor for every 4 youth.'
      @limit = 20
      @site_text = "Below is a list of the sites that are hosting junior high programs this summer. When you select a site, the available sessions will appear."
      @group_type_name =  "Summer Junior High"
    else
      @limit_text = 'You may register up to 30 persons in total. We suggest a ratio of 1 counselor for every 5 youth.'
      @site_text = "Below is a list of the sites that are hosting senior high programs this summer. When you select a site, the available sessions will appear."
      @limit = 30
      @group_type_name =  "Summer Senior High"
    end

    render :partial => "limit_info"
  end

  def get_sites_for_group_type
    #As above, let Summer senior high be the default in the event that an invalid value is passed
    if params[:value] == SessionType.find_by_name("Summer Junior High").id.to_s
       @list_of_sites = Session.sites_for_group_type(params[:value])
    else
       @list_of_sites = Session.sites_for_group_type_senior
    end

    render :partial => "site_selector"
  end

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

    if params[:value] == SessionType.find_by_name("Summer Junior High").id.to_s
       @list_of_sites = Session.alt_sites_for_group_type(params[:value], @session_choices)
    else
       @list_of_sites = Session.sites_for_group_type_senior
    end
    #logger.debug @list_of_sites.inspect

    render :partial => "alt_site_selector"
  end

  def get_sessions_for_type_and_site
    @list_of_sessions = Array.new
    if SessionType.find(params[:value]).name == "Summer Junior High"
      sessions = Session.junior_high.active.find_all_by_site_id(params[:site])
    else
      sessions = Session.senior_high.active.find_all_by_site_id(params[:site])
    end

    sessions.each { |s| @list_of_sessions << s.period}
    @site_name = Site.find(params[:site]).name
    render :partial => "session_selector"
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
    session_choices = params[:session_choices].split(',')
    liaison = Liaison.find(params[:liaison_id])
    logger.debug liaison.inspect
    logger.debug session_choices.inspect
    @registration.church_id = liaison.church_id
    @registration.comments = params[:comments]
    @registration.comments = params[:comments]
    @registration.group_type_id = params[:group_type]
    @registration.liaison_id = liaison.id
    @registration.name = "#{liaison.church.name} #{SessionType.find(params[:group_type]).name}"

    @registration.request1 = session_choices[0]
    @registration.request2 = session_choices[1]
    @registration.request3 = session_choices[2]
    @registration.request4 = session_choices[3]
    @registration.request5 = session_choices[4]
    @registration.request6 = session_choices[5]
    @registration.request7 = session_choices[6]
    @registration.request8 = session_choices[7]
    @registration.request9 = session_choices[8]
    @registration.request10 = session_choices[9]
    @registration.requested_counselors = params[:requested_adults].to_i
    @registration.requested_youth = params[:requested_youth].to_i
    @registration.requested_total = params[:requested_youth].to_i + params[:requested_adults].to_i
    @registration.scheduled = false
    if @registration.save
      @registration_saved = true
      @message = "Save of registration request successful."
      @registration_id = @registration.id
      @deposit_amount = @registration.requested_total * 50
      @processing_charge = (@deposit_amount * 0.029)
      @to_be_charged = @deposit_amount + @processing_charge
      set_registered_flag
      log_activity("Registration Created", "Group Type: #{@registration.type } Total requested: #{@registration.requested_total}")
    else
      @registration_saved = false
      @message = "A problem has occurred saving this registration. Please call the SSP office if you continue to have problems."
    end

    render :partial => 'save_registration_data'

  end

  def set_registered_flag
    liaison = Liaison.find(@registration.liaison_id)
    liaison.registered = true
    liaison.save
    church = Church.find(@registration.liaison_id)
    church.registered = true
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
      @deposit_amount = @registration.requested_total * 50
      p = Payment.record_deposit(@registration.id, @deposit_amount, params[:processing_charge], "cc", @registration.payment_notes)
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
    @matrix = build_schedule("registered", "summer_domestic")
    @senior_high_limit = 60
    render :partial => 'request_matrix', :reg_or_sched => "registered"
  end
  private

  def build_schedule(reg_or_sched, type)

    @schedule = {}
    if type == "summer_domestic" then
      @site_names = Site.order(:listing_priority).find_all_by_active_and_summer_domestic(true, true).map { |s| s.name}
#      @site_names = Site.order(:listing_priority).find_all.map { |s| s.name}
      @period_names = Period.order(:start_date).find_all_by_active_and_summer_domestic(true, true).map { |p| p.name}
#      @period_names = Period.order(:start_date).find_all.map { |p| p.name}
      @title = @page_title = "Domestic Summer Schedule"
    else
      @site_names = Site.order(:listing_priority).find_all_by_active_and_summer_domestic(true, false).map { |s| s.name}
#      @site_names = Site.order(:listing_priority).find_all.map { |s| s.name}
      @period_names = Period.order(:start_date).find_all_by_active_and_summer_domestic(true, false).map { |p| p.name}
#      @period_names = Period.order(:start_date).find_all.map { |p| p.name}
      @title = @page_title = "Special Program Schedule"
    end

    if reg_or_sched == 'scheduled'
      @title += ': Scheduled'
      @page_title += ': Scheduled'
    else
      @title += ': Unscheduled'
      @page_title += ': Unscheduled'
    end

    @period_ordinal = Array.new
    for i in 0..@period_names.size - 1 do
      @period_ordinal[i] = @period_names[i]
    end

    @site_ordinal = Array.new
    for i in 0..@site_names.size - 1 do
      @site_ordinal[i] = @site_names[i]
    end

    @registration_matrix = Array.new(@site_names.size + 1){ Array.new(@period_names.size + 1, 0)}
    @scheduled_matrix = Array.new(@site_names.size + 1){ Array.new(@period_names.size + 1, 0)}
    @session_id_matrix = Array.new(@site_names.size + 1){ Array.new(@period_names.size + 1, 0)}

    Registration.all(:conditions => "(request1 IS NOT NULL) AND (scheduled = 'f')").each do |r|
        @session = Session.find(r.request1)
        @site = Site.find(@session.site_id)

        @period = Period.find(@session.period_id)
        @row_position = @site_ordinal.index(@site.name)
        @column_position = @period_ordinal.index(@period.name)
        @session_id_matrix[@row_position][@column_position] = @session.id
        @registration_matrix[@row_position][@column_position] += r.requested_counselors + r.requested_youth
          unless (@column_position.nil? || @row_position.nil?)
          end

    end

    ScheduledGroup.active_program.each do |r|
        @session = Session.find(r.session_id)
        @site = Site.find(@session.site_id)
        @period = Period.find(@session.period_id)
        @row_position = @site_ordinal.index(@site.name)
        @column_position = @period_ordinal.index(@period.name)
        @session_id_matrix[@row_position][@column_position] = @session.id
        @scheduled_matrix[@row_position][@column_position] += r.current_total
          unless (@column_position.nil? || @row_position.nil?)
          end
    end
#total the rows and columns
    @reg_total = 0
    @sched_total = 0
    for i in 0..@site_names.size - 1 do
      for j in 0..@period_names.size - 1 do
        @reg_total += @registration_matrix[i][j]
        @sched_total += @scheduled_matrix[i][j]
      end
      @registration_matrix[i][@period_names.size] = @reg_total
      @scheduled_matrix[i][@period_names.size] = @sched_total
      @reg_total = @sched_total = 0
    end

    for j in 0 ..@period_names.size do
      for i in 0..@site_names.size - 1 do
        @reg_total = @reg_total + @registration_matrix[i][j]
        @sched_total = @sched_total + @scheduled_matrix[i][j]
      end
      @registration_matrix[@site_names.size][j] = @reg_total
      @scheduled_matrix[@site_names.size][j] = @sched_total
      @reg_total = @sched_total = 0
    end
    #Grand total
    @reg_total = @sched_total = 0
    for i in 0..@site_names.size - 1 do
      @reg_total = @reg_total + @registration_matrix[i][@period_names.size]
      @sched_total = @sched_total + @scheduled_matrix[i][@period_names.size]
    end
    @registration_matrix[@site_names.size][@period_names.size] = @reg_total
    @scheduled_matrix[@site_names.size][@period_names.size] = @sched_total

    @period_names << "Total"
    @site_names << "Total"

    #Replace zeros in cells which do not represent an active session
    for i in 0..@site_names.size - 2 do
      site = Site.active.summer_domestic.find_by_name(@site_names[i]).id
      for j in 0..@period_names.size - 2 do
        period = Period.active.summer_domestic.find_by_name(@period_names[j]).id
        if Session.where('site_id = ? AND period_id =  ?', site, period).size == 0
          @registration_matrix[i][j] = "-"
        end
      end
    end

    @schedule = { :site_count => @site_names.size - 1, :period_count => @period_names.size - 1,
                  :site_names => @site_names, :period_names => @period_names,
                  :registration_matrix => @registration_matrix, :scheduled_matrix => @scheduled_matrix,
                  :session_id_matrix => @session_id_matrix, :reg_or_sched => reg_or_sched, :type => type}
  end

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

