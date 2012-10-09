class RegistrationController < ApplicationController
  load_and_authorize_resource
  layout 'admin_layout'

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
    #@registration=Registration.new
    #@registration.liaison_id = params[:id]
    #@liaison = Liaison.find(params[:id])
    render 'new'
  end
  #this is the old create method
  #def create       #triggered by register view
  #  @registration = Registration.new(params[:registration])
  #  authorize! :create, @registration
  #  if (@registration.valid?)
  #    @registration.save!
  #    flash[:notice] = "Successful completion of Step 1!"
  #    redirect_to edit_registration_path(:id => @registration.id)
  #  else
  #    @liaisons = Liaison.all.map { |l| [l.name, l.id ] }
  #    @group_types = SessionType.all.map { |s| [s.name, s.id ] }
  #    @title = "Register A Group"
  #    render "register"
  #  end
  #end
  def index
    @title = "Manage Groups"
  end

  def register                #prior to display of register view
    @registration = Registration.new
    authorize! :create, @registration
    @liaisons = Liaison.all.map { |l| [l.name, l.id ]}
    @group_types = SessionType.all.map { |s| [s.name, s.id ]}
    @title = "Register A Group"
    @page_title = "Register A Group"
    render "register"
  end
  def edit              #prior to /:id/edit view
    @registration = Registration.find(params[:id])
    authorize! :edit, @registration
    @liaison = Liaison.find(@registration.liaison_id)
    @church = Church.find(@liaison.church_id)
    @group_type = SessionType.find(@registration.group_type_id)
    @temp = Array.new()
    @temp << "None" << 0
    @sessions = Session.find_all_by_session_type_id(@registration.group_type_id).map { |s| [s.name, s.id ]}
    @sessions.insert(0, @temp)
    @title = "Registration Step 2"
    @page_title = "Register A Group: Step 2"
  end

  def step2?
    @registration.registration_step == 'Step 2'
  end

  def step3?
    @registration.registration_step == 'Step 3'
  end

  def update          #follows posting of edit and process_payment forms
    @registration = Registration.find(params[:id])
    authorize! :update, @registration
    @liaison = Liaison.find(@registration.liaison_id)
    @group_type = SessionType.find(@registration.group_type_id)
    @registration.church_id = @liaison.church_id
    total_requested = @registration.requested_counselors + @registration.requested_youth
    @registration.requested_total = total_requested
    @registration.scheduled = false
    @church = Church.find(@liaison.church_id)
    @registration.update_attributes(params[:registration])
    @payment_types = 'Check', 'Credit Card', 'Cash'


    if (step2?) then
      if @registration.update_attributes(params[:registration])
        flash[:notice] = "Successful completion of Step 2"
        redirect_to registration_payment_path(:id => @registration.id)
      else
        @sessions = Session.all.map  { |s| [s.name, s.id ]}
        @sessions.insert(0, @temp)
        @title = "Registration Step 2"
        @page_title = "Register A Group: Step 3"
        render "edit"
      end
    end

    if (step3?)
      if @registration.update_attributes(params[:registration]) then
        @payment = Payment.new
        @payment.registration_id = @registration.id
        @payment.payment_method = @registration.payment_method
        @payment.payment_amount=@registration.amount_paid
        @payment.payment_date=Date.today
        @payment.payment_notes=@registration.payment_notes
        @payment.payment_type = 'Initial'
        @church.registered=true
        if @payment.save && @church.save then
          flash[:notice] = "Successful completion of step 3"
          redirect_to registration_success_path(:id => @registration.id)
        else
          flash[:error] = "Save of payment/registration failed."
          @title = "Registration Step 3"
          @page_title = "Register A Group: Step 3"
          redirect_to registration_payment_path(:id => @registration.id)
        end
      end
    end
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
    @alt_sessions = Session.find_all_by_session_type_id(@registration.group_type_id).map  { |s| [s.name, s.id]}
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

  def program_session
    @requests = Registration.find_all_by_request1(params[:id])
    session = Session.find(params[:id])
    @session_week = Period.find(session.period.id).name
    @session_site = Site.find(session.site_id).name
  end


  def get_limit_info
    #Let Summer senior high be the default in the event that an invalid value is passed
    if params[:value] == SessionType.find_by_name("Summer Junior High").id.to_s
      @limit_text = 'You may register up to 20 persons in total. We suggest a ratio of 1 counselor for every 3 to 4 youth.'
      @limit = 20
      @site_text = "Below is a dropdown list of the sites that are hosting junior high programs this summer. When you select a site, the available weeks will appear."
      @group_type_name =  "Summer Junior High"
    else
      @limit_text = 'You may register up to 30 persons in total. We suggest a ratio of 1 counselor for every 4 to 5 youth.'
      @site_text = "Below is a dropdown list of the sites that are hosting senior high programs this summer. When you select a site, the available weeks will appear."
      @limit = 30
      @group_type_name =  "Summer Junior High"
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

    #As above, let Summer senior high be the default in the event that an invalid value is passed
    logger.debug @session_choices
    logger.debug @session_choices_names.inspect

    if params[:value] == SessionType.find_by_name("Summer Junior High").id.to_s
       @list_of_sites = Session.alt_sites_for_group_type(params[:value], @session_choices)
    else
       @list_of_sites = Session.sites_for_group_type_senior
    end
    logger.debug @list_of_sites.inspect

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
    @registration.requested_counselors = params[:requested_adults].to_i
    @registration.requested_youth = params[:requested_youth].to_i
    @registration.requested_total = params[:requested_youth].to_i + params[:requested_adults].to_i
    @registration.scheduled = false
    if @registration.save
      @registration_saved = true
      @message = "Save of registration request successful."
      @registration_id = @registration.id
    else
      @registration_saved = false
      @message = "A problem has occurred saving this registration. Please call the SSP office if you continue to have problems."
    end
    render :partial => "save_registration_data"

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

#    Registration.find_all_by_request1_and_scheduled(not nil, false).each do |r|
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
        @reg_total = @reg_total + @registration_matrix[i][j]
        @sched_total = @sched_total + @scheduled_matrix[i][j]
      end
      @registration_matrix[i][@period_names.size] = @reg_total
      @scheduled_matrix[i][@period_names.size] = @sched_total
      @reg_total = @sched_total = 0
    end

    @reg_total = 0
    @sched_total = 0
    for j in 0..@period_names.size - 1 do
      for i in 0..@site_names.size - 1 do
        @reg_total = @reg_total + @registration_matrix[i][j]
        @sched_total = @sched_total + @scheduled_matrix[i][j]
      end
      @registration_matrix[@period_names.size - 1][j] = @reg_total
      @scheduled_matrix[@period_names.size - 1][j] = @sched_total
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
    @schedule = { :site_count => @site_names.size - 1, :period_count => @period_names.size - 1,
                  :site_names => @site_names, :period_names => @period_names,
                  :registration_matrix => @registration_matrix, :scheduled_matrix => @scheduled_matrix,
                  :session_id_matrix => @session_id_matrix, :reg_or_sched => reg_or_sched, :type => type}
  end


 end

