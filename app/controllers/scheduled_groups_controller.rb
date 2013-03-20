class ScheduledGroupsController < ApplicationController
  skip_authorize_resource :only => :program_session
  authorize_resource
  require 'csv'
  require 'erb'
  before_filter :check_for_cancel, :only => [:update]
  before_filter :check_for_submit_changes, :only => [:update]
  layout 'admin_layout'

  def program_session
    if params[:session] #MySSP is calling this
      session = Session.find(params[:session])
    else
      session = Session.find(params[:id])
    end
    @groups = ScheduledGroup.active_program.find_all_by_session_id(session.id)
    @session_week = Period.find(session.period.id).name
    @session_site = Site.find(session.site_id).name
    @page_title = "Groups Scheduled for #{@session_week} #{@session_site}"
  end

  def new
    @registration = Registration.find(params[:reg])
    @scheduled_group = ScheduledGroup.new(:church_id => @registration.church_id,
                                          :name => @registration.name, :registration_id => @registration.id,
                                          :current_youth => @registration.requested_youth,
                                          :current_counselors => @registration.requested_counselors,
                                          :current_total => @registration.requested_total,
                                          :liaison_id => @registration.liaison_id, :session_id => params[:id],
                                          :group_type_id => @registration.group_type_id,
                                          :scheduled_priority => params[:priority],
                                          :second_payment_total => 0,
                                          :comments => @registration.comments)
    if @scheduled_group.valid?
      @scheduled_group.save!
      roster = Roster.create!(:group_id => @scheduled_group.id,
                              :group_type => SessionType.find(Session.find(@scheduled_group.session_id).session_type_id).id)
      @scheduled_group.update_attribute('roster_id', roster.id)
      @registration.update_attribute('scheduled', true)
      liaison = Liaison.find(@registration.liaison_id)
      liaison.update_attribute(:scheduled, true)
      payments = Payment.find_all_by_registration_id(@registration.id)
      payments.each do |p|
        p.update_attribute('scheduled_group_id', @scheduled_group.id)
      end
      flash[:notice] = "Group has been successfully scheduled."
    else
      flash[:error] = @scheduled_group.errors
    end
  end

  def update
    @scheduled_group = ScheduledGroup.find(params[:id])
    case params[:commit]
      when 'Print This Page'

      when 'Send Confirmation Email'
        UserMailer.schedule_confirmation(@scheduled_group).deliver
        flash[:notice] = "Confirmation email has been sent for group #{@scheduled_group.name}."
    end
    redirect_to admin_registrations_path
  end

  def success
    require 'erb'
    @title = @page_title = "Scheduling Complete"
    @scheduled_group = ScheduledGroup.find(params[:id])
    @session = Session.find(@scheduled_group.session_id)
    filename = File.join('app', 'views', 'email_templates', 'schedule_confirmation.text.erb')
    f = File.open(filename)
    body = f.read.gsub(/^  /, '')
    @site = Site.find(@session.site_id).name
    period = Period.find(@session.period_id)
    liaison = Liaison.find(@scheduled_group.liaison_id)
    @current_date = Time.now.strftime("%a, %b %d, %Y")
    @first_name = liaison.first_name
    @week = period.name
    @start_date = period.start_date.strftime("%a, %b %d, %Y")
    if @session.session_type_junior_high?
      end_date = period.end_date - 1
      @end_date = end_date.strftime("%a, %b %d, %Y")
    else
      @end_date = period.end_date.strftime("%a, %b %d, %Y")
    end
    @group_name = @scheduled_group.name
    @church_name = Church.find(@scheduled_group.church_id).name
    @liaison_name = liaison.name
    @current_youth = @scheduled_group.current_youth
    @current_counselors = @scheduled_group.current_counselors
    @current_total = @scheduled_group.current_total
    message = ERB.new(body, 0, "%<>")
    @email_body = message.result(binding)
  end

  def edit
    @scheduled_group = ScheduledGroup.find(params[:id])
    @session = Session.find(@scheduled_group.session_id)
    @sessions = Session.active.find_all_by_session_type_id(@scheduled_group.group_type_id).sort_by{|e| e.name}.map { |s| [s.name, s.id ]}
    @liaison = Liaison.find(@scheduled_group.liaison_id)
    @title = @page_title = "Change Schedule"
    @notes = String.new
  end


  def change_success
    @scheduled_group = ScheduledGroup.find(params[:id])
    current_change = ChangeHistory.find(params[:change_id])
    @session = Session.find(@scheduled_group.session_id)
    @site = Site.find(@session.site_id).name
    period = Period.find(@session.period_id)
    liaison = Liaison.find(@scheduled_group.liaison_id)
    @current_date = Time.now.strftime("%a, %b %d, %Y")
    @first_name = liaison.first_name
    @week = period.name
    @start_date = period.start_date.strftime("%A, %B %d, %Y at %l:%M %p")
    @end_date = @session.period.end_date.strftime("%A, %B %d, %Y at %l:%M %p")
    @group_name = @scheduled_group.name
    @church_name = Church.find(@scheduled_group.church_id).name
    @liaison_name = liaison.name
    @current_youth = @scheduled_group.current_youth
    @current_counselors = @scheduled_group.current_counselors
    @current_total = @scheduled_group.current_total
    @old_youth = current_change.old_youth
    @old_counselors = current_change.old_counselors
    @old_session = current_change.old_session
    @change_line1 = @change_line2 = @change_line3 = ''
    if current_change.site_change?
        @change_line1 = 'The site was changed from ' + current_change.old_site + ' to ' + @site + '.'
    end
    if current_change.week_change?
        @change_line2 = 'The week was changed from ' + current_change.old_week + ' to ' + @week + '.'
    end
    if current_change.count_change?
        @change_line3 = 'Total registration was changed from ' + current_change.old_total.to_s + ' to ' + @current_total.to_s + '.'
    end

    filename = File.join('app', 'views', 'email_templates', 'schedule_change.text.erb')
    f = File.open(filename)
    body = f.read.gsub(/^  /, '')

    message = ERB.new(body, 0, "%<>")
    @email_body = message.result(binding)
    @title = @page_title = "Change Success"
  end

  def make_adjustment

    scheduled_group = ScheduledGroup.find(params[:id])
    liaison_name = Liaison.find(scheduled_group.liaison_id).name
    site_name = Site.find(Session.find(scheduled_group.session_id).site_id).name
    period_name = Period.find(Session.find(scheduled_group.session_id).period_id).name
    start_date = Period.find(Session.find(scheduled_group.session_id).period_id).start_date
    end_date = Period.find(Session.find(scheduled_group.session_id).period_id).end_date
    session_type = SessionType.find(Session.find(scheduled_group.session_id).session_type_id).name

    @screen_info = {:scheduled_group => scheduled_group,
      :site_name => site_name, :period_name => period_name, :start_date => start_date,
      :end_date => end_date,  :session_type => session_type,:adjustment => adjustment,
      :liaison_name => liaison_name}
    @title = "Make adjustment for: #{scheduled_group.name}"
  end


  def update_group_change
      @group_id = params[:id]
      @group = ScheduledGroup.find(@group_id)
      if can? :move, @group
        update_all_fields
      else
        update_only_counts
      end
  end

  def invoice
    @group= ScheduledGroup.find(params[:id])
    @page_title = "Invoice for: #{@group.name}"
    @registration = Registration.find(@group.registration_id)
  end


  def statement
    @group = ScheduledGroup.find(params[:id])
    @registration = Registration.find(@group.registration_id)
  end

  def invoice_report
    @groups = ScheduledGroup.active.active_program
    @page_title = 'Invoice Report'
    respond_to do |format|
      format.csv { create_csv("invoice-#{Time.now.strftime("%Y%m%d")}.csv") }
      format.html { @title = 'Invoice Report'}
    end
  end

  def two_year_report
    @page_title = 'Two Year Participation Report'
    @groups = Array.new
    current_groups = ScheduledGroup.active.active_program
    current_groups.each do |g|
      if ScheduledGroup.program_2012.find_by_church_id(g.church_id)
        @groups << g.church
      end
    end
    @groups.uniq!

    respond_to do |format|
      format.csv { create_csv("two-year-report-#{Time.now.strftime("%Y%m%d")}.csv") }
      format.html { @title = 'Two Year Participation'}
    end

  end

  def tshirt_report
    @groups = build_tshirt_report
    @page_title = 'T-Shirt Report'
    respond_to do |format|
      format.csv { create_csv("tshirt-orders-#{Time.now.strftime("%Y%m%d")}.csv") }
      format.html { @title = 'T-Shirt Order Report'}
    end
  end


private

  def create_csv(filename = nil)

      if request.env['HTTP_USER_AGENT'] =~ /msie/i
        headers['Pragma'] = 'public'
        headers["Content-type"] = "text/plain"
        headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
        headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
        headers['Expires'] = "0"
      else
        headers["Content-Type"] ||= 'text/csv'
        headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
      end
  end

  def build_invoice_report_delete

    invoices = []

    ScheduledGroup.all.each do |group|
      church = Church.find(group.church_id)
      full_invoice = calculate_invoice_data(group.id)

    if full_invoice[:amount_paid] > full_invoice[:deposit_amount]
      dep_paid = full_invoice[:deposit_amount]
      dep_outstanding = 0
      remaining_balance = full_invoice[:amount_paid] - dep_paid
    else
      dep_paid = full_invoice[:amount_paid]
      dep_outstanding = full_invoice[:deposit_amount ] - dep_paid
      remaining_balance = 0
    end

    if remaining_balance > full_invoice[:second_payment_amount]     #second payment is covered
      sec_paid = full_invoice[:second_payment_amount]
      sec_outstanding = 0
      remaining_balance = remaining_balance - sec_paid
    else
      if remaining_balance > 0                                      #partially paid second payments
        sec_paid = remaining_balance
        sec_outstanding = full_invoice[:second_payment_amount] - sec_paid
        remaining_balance = 0
      else                                                          #zero remaining balance after second
        sec_paid = 0
        sec_outstanding = full_invoice[:second_payment_amount]
      end
    end

    if remaining_balance > full_invoice[:final_payment_amount]     #final payment is covered
      final_paid = full_invoice[:final_payment_amount]
      final_outstanding = 0
      remaining_balance = remaining_balance - final_paid
    else
      if remaining_balance > 0                                      #partially paid final payments
        final_paid = remaining_balance
        final_outstanding = full_invoice[:final_payment_amount] - final_paid
        remaining_balance = 0
      else                                                          #zero remaining balance after final
        final_paid = 0
        final_outstanding = full_invoice[:final_payment_amount]
      end
    end

    invoice = {:church_name => trim(church.name), :group_name => trim(group.name), :youth => group.current_youth,
                    :counselors => group.current_counselors,
                    :group_id => group.id,
                    :church_id => church.id,
                    :deposits_due => full_invoice[:deposits_due_count],
                    :deposits_paid => dep_paid,
                    :deposits_outstanding => dep_outstanding,
                    :second_payments_due => full_invoice[:second_payments_due_count],
                    :second_payments_paid => sec_paid,
                    :second_payments_outstanding => sec_outstanding,
                    :final_payments_due => group.current_total,
                    :final_payments_paid => final_paid,
                    :final_payments_outstanding => final_outstanding,
                    :adjustments => full_invoice[:adjustment_total],
                    :current_balance => full_invoice[:current_balance],
                    :total_due => full_invoice[:total_due] }

    invoices << invoice
  end
    invoices
  end

  def build_tshirt_report

    groups = []

    ScheduledGroup.all.each do |g|
      church = Church.find(g.church_id)
      discrepancy_value = total_ordered = number_xsmall = number_small = number_medium = number_large = number_xlarge = number_xx = number_xxx = 0
      begin
        roster = Roster.find_by_group_id(g.id)
        #logger.debug roster.inspect
        roster_items = RosterItem.find_all_by_roster_id(roster.id)
        roster_items.each do |r|
        #roster_items.each do |r|
        #  logger.debug r.shirt_size
          case r.shirt_size
            when "XS"
              number_xsmall += 1
            when "S"
              number_small += 1
            when "M"
              number_medium += 1
            when "L"
              number_large += 1
            when "XL"
              number_xlarge += 1
            when "XXL"
              number_xx += 1
            when "XXXL"
              number_xxx += 1
            else puts "Unknown size encountered: #{r.shirt_size}"
          end
        end
      rescue
        puts "No roster found for #{church.name}"
      end
      total_ordered = number_xsmall + number_small + number_medium + number_large + number_xlarge + number_xx + number_xxx
      discrepancy_value = g.current_counselors + g.current_youth - total_ordered
      if discrepancy_value == 0
        discrepancy = "None"
      else if discrepancy_value > 0
        discrepancy = discrepancy_value.to_s + " t-shirt orders are missing."
        else
          discrepancy = discrepancy_value.to_s + " too many t-shirts were ordered."
        end
      end

      group = {:church_name => trim(church.name),
                    :group_id => g.id,
                    :site => g.session.site.name,
                    :period_name => g.session.period.name,
                    :youth => g.current_youth,
                    :counselors => g.current_counselors,
                    :total_registered => g.current_counselors + g.current_youth,
                    :number_small => number_small,
                    :number_xsmall => number_xsmall,
                    :number_medium => number_medium,
                    :number_large => number_large,
                    :number_xlarge => number_xlarge,
                    :number_xx => number_xx,
                    :number_xxx => number_xxx,
                    :total_ordered => total_ordered,
                    :discrepancy => discrepancy }
    #logger.debug group.inspect
    groups << group
  end
    groups

  end

  def trim(s)
    if s.instance_of?(String)
      s.chomp.strip!
    end
    return s
  end


  def create_invoice_items_delete(invoice)

    #Create invoice_items array
    invoice_items = Array[]
    item = ["Description", "Number of Persons", "Amount per Person", "Total"]
    invoice_items << item

    item = ["Deposits", invoice[:deposits_due_count],
      number_to_currency(invoice[:payment_schedule].deposit),
      number_to_currency(invoice[:deposit_amount])]
    invoice_items << item

    item = ["2nd Payments", invoice[:second_payments_due_count],
      number_to_currency(invoice[:payment_schedule].second_payment),
      number_to_currency(invoice[:second_payment_amount])]
    invoice_items << item

#Only include the final payments if the second payment has been made
    unless @group.second_payment_date.nil?
      item = ["Final Payments", @group.current_total,
        number_to_currency(invoice[:payment_schedule].final_payment),
        number_to_currency(invoice[:final_payment_amount])]
      invoice_items << item
    end

    item = ["Total", "", "", number_to_currency(invoice[:deposit_amount] + invoice[:second_payment_amount] +
      invoice[:final_payment_amount])]
    invoice_items << item

    item = ["Paid to date", "", "", number_to_currency(invoice[:amount_paid])]
    invoice_items << item

    if invoice[:second_late_payment_required?]
      item = ["Second Payment Late Charge", "", "", number_to_currency(invoice[:second_late_payment_amount])]
      invoice_items << item
    end

    if invoice[:final_late_payment_required?]
      item = ["Second Payment Late Charge", "", "", number_to_currency(invoice[:final_late_payment_amount])]
      invoice_items << item
    end

    item = ["Less Adjustments", "", "", number_to_currency(invoice[:adjustment_total])]
    invoice_items << item

    item = ["Balance Due", "", "", number_to_currency(invoice[:current_balance])]
    invoice_items << item

  end


  def update_all_fields
      new_values = params[:scheduled_group]
      site_change = week_change = count_change = false
      new_session_name = Session.find(new_values[:session_id]).name
      old_session_name = Session.find(@group.session_id).name
      new_week_name = Period.find(Session.find(new_values[:session_id]).period_id).name
      old_week_name = Period.find(Session.find(@group.session_id).period_id).name
      new_site_name = Site.find(Session.find(new_values[:session_id]).site_id).name
      old_site_name = Site.find(Session.find(@group.session_id).site_id).name
      if new_week_name != old_week_name then week_change = true end
      if new_site_name != old_site_name then site_change = true end

      new_total = new_values[:current_youth].to_i  + new_values[:current_counselors].to_i

      if (new_total != @group.current_total) || new_values[:current_youth].to_i != @group.current_youth  then
        count_change = true
      end

      change_record = ChangeHistory.new(:group_id => @group_id,
         :new_counselors => new_values[:current_counselors],:old_counselors => @group.current_counselors,
         :new_youth => new_values[:current_youth],:old_youth => @group.current_youth,
         :updated_by => @current_admin_user.id,
         :new_total => (new_values[:current_counselors].to_i + new_values[:current_youth].to_i),:old_total => @group.current_total,
         :new_site => new_site_name,:old_site => old_site_name,
         :new_week => new_week_name,:old_week => old_week_name,
         :new_session => new_session_name,:old_session => old_session_name,
         :site_change => site_change,
         :week_change => week_change,
         :count_change => count_change,
         :notes => @notes)
       if change_record.save! then
          flash[:notice] = "You have successfully completed this group change."
       else
          flash[:error] = "Update of change record failed for unknown reason."
          render "edit"
       end

      activity_description = ''
      if count_change
        activity_description += "Count was changed from #{@group.current_total} to #{new_total}. "
      end
      if site_change || week_change
        activity_description += "Session was changed from #{@group.session.name} to #{Session.find(new_values[:session_id]).name}."
      end

#Update ScheduledGroup
      if count_change then
        @group.current_counselors = new_values[:current_counselors]
        @group.current_youth = new_values[:current_youth]
        @group.current_total = new_total
      end


      if site_change || week_change then
        @group.session_id = new_values[:session_id]
      end

      if @group.second_payment_total.nil? then
        @group.second_payment_total= 0
      end

      if @group.save then

        log_activity("Group Update", activity_description)
        redirect_to change_confirmation_path(@group_id, :change_id => change_record.id)
      else
          flash[:error] = "Update of scheduled group record failed for unknown reason (1)."
      end
  end

  def update_only_counts

     new_values = params[:scheduled_group]
     new_total = new_values[:current_youth].to_i  + new_values[:current_counselors].to_i

     if (new_total != @group.current_total) then
        count_change = true
     else
       count_change = false
     end

     if new_total > @group.current_total
        flash[:error] = "To increase your enrollment, you must contact the office."
        @scheduled_group = ScheduledGroup.find(params[:id])
        authorize! :read, @scheduled_group
        @session = Session.find(@scheduled_group.session_id)
        @sessions = Session.find_all_by_session_type_id(@scheduled_group.group_type_id).map { |s| [s.name, s.id ]}
        @liaison = Liaison.find(@scheduled_group.liaison_id)
        @title = "Make Changes to Group"
        params[:id => @group.id]
        render "edit"
     else
        change_record = ChangeHistory.new(:group_id => @group_id,
         :new_counselors => new_values[:current_counselors],:old_counselors => @group.current_counselors,
         :new_youth => new_values[:current_youth],:old_youth => @group.current_youth,
         :updated_by => 1,
         :new_total => new_total,:old_total => @group.current_total,
         :count_change => count_change,
         :notes => @notes)
       if change_record.save! then
          flash[:notice] = "You have successfully completed this group change."
       else
          flash[:error] = "Update of change record failed for unknown reason."
          render "edit"
       end

#Update ScheduledGroup
        if count_change then
          @group.current_counselors = new_values[:current_counselors]
          @group.current_youth = new_values[:current_youth]
          @group.current_total = new_values[:current_counselors].to_i + new_values[:current_youth].to_i
        end

        if @group.save then
          log_activity("Group Update", "Count changed to #{@group.current_total}")
          redirect_to change_confirmation_path(@group_id, :change_id => change_record.id)
        else
          flash[:error] = "Update of scheduled group record failed for unknown reason (2)."
          render "edit"
        end
     end
  end

  def check_for_submit_changes
    if params[:commit] == 'Submit Changes'
      update_group_change
    end
  end

  def check_for_cancel
    if params[:commit] == 'Cancel'
      ScheduledGroup.delete(params[:id])
      redirect_to admin_registrations_path
    end
  end

  def number_to_currency(number)
    "$" + sprintf('%.2f', number)
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

  def shorten(s)
    limit = 40
    if s.length > limit
      s = s[0, limit] + '...'
    end
    s
  end
end
