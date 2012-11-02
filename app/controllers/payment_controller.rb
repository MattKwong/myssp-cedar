class PaymentController < ApplicationController
  authorize_resource
  #before_filter :check_for_cancel, :only => [:create]
  layout 'admin_layout'
#  def show
#    redirect_to admin_payment_path(params[:id])
#  end

  def new
    @payment = Payment.new()
    @group_status = params[:group_status]
    @payment_methods = 'Check', 'Credit Card', 'Cash'
    if @group_status == 'registration'
      @payment_types = 'Deposit', 'Other'
      @group = Registration.find(params[:group_id])
      #site_name = Site.find(Session.find(group.request1).site_id).name
      #period_name = Period.find(Session.find(group.request1).period_id).name
      #start_date = Period.find(Session.find(group.request1).period_id).start_date
      #end_date = Period.find(Session.find(group.request1).period_id).end_date
      #session_type = SessionType.find(Session.find(group.request1).session_type_id).name
    else
      @payment_types = 'Deposit', 'Second', 'Final', 'Other'
      @group = ScheduledGroup.find(params[:group_id])
      #site_name = Site.find(Session.find(group.session_id).site_id).name
      #period_name = Period.find(Session.find(group.session_id).period_id).name
      #start_date = Period.find(Session.find(group.session_id).period_id).start_date
      #end_date = Period.find(Session.find(group.session_id).period_id).end_date
      #session_type = SessionType.find(Session.find(group.session_id).session_type_id).name
    end

    #liaison_name = Liaison.find(group.liaison_id).name
    #
    #@screen_info = {:scheduled_group => group, :group_status => params[:group_status],
    #  :site_name => site_name, :period_name => period_name, :start_date => start_date,
    #  :end_date => end_date,  :session_type => session_type, :payment => payment, :payment_types => payment_types,
    #  :liaison_name => liaison_name, :payment_methods => payment_methods}
    @page_title = "Make payment for group: #{@group.name}"
  end

  def cc_payment #payments not made as part of the registration wizard
    @group_status = params[:group_status]
    @group_status == 'registration' ? @group = Registration.find(params[:id]) : Registration.find(params[:id])
    @page_title = "Make Credit Card Payment for #{@group.name}"
    render 'cc_payment'
  end

  def process_cc_payment
    token = params[:payment_tracking_number]
    @group = Registration.find(params[:id])
    @payment_error_message = ''
    begin
      to_be_charged = (100 * params[:amount_paid].to_f).to_i
      logger.debug to_be_charged
      logger.debug token
      charge = Stripe::Charge.create(
          :amount=> to_be_charged,
          :currency=>"usd",
          :card => token,
          :description => @group.name)
    rescue Stripe::InvalidRequestError => e
      @payment_error_message = "There has been a problem processing your credit card."
      logger.debug e.message
    rescue Stripe::CardError => e
      @payment_error_message = e.message
      logger.debug e.message
    end

    if e
      render :partial => 'process_cc_payment'
    else
      p = Payment.record_deposit(@group.id, params[:payment_amount], params[:processing_charge], "cc", params[:payment_comments])
      if p
        log_activity("CC Payment", "Group: #{@group.name} Fee amount: $#{sprintf('%.2f', params[:payment_amount].to_f)} Processing chg: $#{sprintf('%.2f', params[:processing_charge].to_f)}")
        UserMailer.cc_payment_confirmation(@group, p, params).deliver
        render :partial => 'process_cc_payment'
      else
        @payment_error_message = "Unsuccessful save of payment record - please contact the SSP office."
        render :partial => 'process_cc_payment'
      end
    end
  end


  def create

    payment = Payment.new(params[:payment])

    if (params[:group_status] == 'registration')
      group = Registration.find(params[:group_id])
      payment.registration_id = group.id
    else
      group = ScheduledGroup.find(params[:group_id])
      payment.scheduled_group_id = group.id
    end

    if payment.valid?
      if payment.payment_type == 'Second'
        group = ScheduledGroup.find(payment.scheduled_group_id)
        group.second_payment_date = payment.payment_date
        group.second_payment_total=group.current_total
        if group.save!
          log_activity("Scheduled Group second payment date recorded: ", "#{payment.payment_date} for #{group.name}")
        else
          flash[:error] = "Unable to updated group record."
        end
      end
      payment.save!
      log_activity("Payment by check", "$#{sprintf('%.2f', payment.payment_amount)} paid for #{group.name}")
      UserMailer.payment_confirmation(group, params).deliver
      flash[:notice] = "Successful entry of new payment."
      redirect_to myssp_path(:id => group.liaison_id)
    else
      flash[:error] = "A problem occurred in creating this payment."
      payment = Payment.new()
      payment_methods = 'Check', 'Credit Card', 'Cash'
      if (params[:group_status] == 'registration')
        payment_types = 'Deposit', 'Other'
        group = Registration.find(params[:group_id])
        site_name = Site.find(Session.find(group.request1).site_id).name
        period_name = Period.find(Session.find(group.request1).period_id).name
        start_date = Period.find(Session.find(group.request1).period_id).start_date
        end_date = Period.find(Session.find(group.request1).period_id).end_date
        session_type = SessionType.find(Session.find(group.request1).session_type_id).name
      else
        payment_types = 'Deposit', 'Second', 'Final', 'Other'
        group = ScheduledGroup.find(params[:group_id])
        site_name = Site.find(Session.find(group.session_id).site_id).name
        period_name = Period.find(Session.find(group.session_id).period_id).name
        start_date = Period.find(Session.find(group.session_id).period_id).start_date
        end_date = Period.find(Session.find(group.session_id).period_id).end_date
        session_type = SessionType.find(Session.find(group.session_id).session_type_id).name
      end

      liaison_name = Liaison.find(group.liaison_id).name

      @screen_info = {:scheduled_group => group, :group_status => params[:group_status],
                        :site_name => site_name, :period_name => period_name, :start_date => start_date,
                        :end_date => end_date,  :session_type => session_type, :payment => payment, :payment_types => payment_types,
                        :liaison_name => liaison_name, :payment_methods => payment_methods}
        @page_title = "Record payment for: #{group.name}"
      render "payment/new"
    end
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
