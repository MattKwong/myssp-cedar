class PaymentController < ApplicationController
  authorize_resource
  #before_filter :check_for_cancel, :only => [:create]
  layout 'admin_layout'

  def cc_payment #payments not made as part of the registration wizard, groups not yet scheduled
    @group_status = params[:group_status]
    @registration_id = params[:id]
    @group = Registration.find(@registration_id )
    @group_status == 'registration' ? @group = Registration.find(params[:id]) : Registration.find(params[:id])
    @page_title = "Make Credit Card Payment for #{@group.name}"
    render 'cc_payment'
  end

  def process_cc_payment   #for a registered but not scheduled group
    group_id = params[:reg_id]
    cc_payment_amount = params[:payment_amount]
    cc_amount_to_be_charged = params[:amount_to_be_charged]
    cc_processing_charge = params[:processing_charge]
    token = params[:token]
    payment_notes = params[:payment_notes]
    group_status = params[:group_status]

    @group = Registration.find(group_id)
    @payment_error_message = ''
      begin
        to_be_charged = (100 * cc_amount_to_be_charged.to_f).to_i
        charge = Stripe::Charge.create(
            :amount=> to_be_charged,
            :currency=>"usd",
            :card => token,
            :description => @group.name)
      rescue Stripe::InvalidRequestError => e
        @payment_error_message = "There has been a problem processing your credit card."
      rescue Stripe::CardError => e
        flash[:error] = @payment_error_message = e.message
      end

      if e
        render 'cc_payment'
      else
        p = Payment.record_deposit(group_id, cc_payment_amount, cc_processing_charge, "cc", payment_comments)
        if p
          log_payment_activity("CC Payment", "Group: #{@group.name} Fee amount: $#{sprintf('%.2f', cc_payment_amount.to_f)} Processing chg: $#{sprintf('%.2f', cc_processing_charge.to_f)}")
          UserMailer.cc_payment_confirmation(@group, p, cc_payment_amount, cc_processing_charge, payment_comments, group_status).deliver
          #flash[:notice] = "Successful entry of new payment."
          #redirect_to myssp_path(:id => @group.liaison_id)
        else
          @payment_error_message = "Unsuccessful save of payment record - please contact the SSP office."
        end
        render 'cc_payment'
      end
  end

  def new
    @payment = Payment.new()
    @group_status = params[:group_status]
    current_admin_user.admin? ? (@payment_methods = 'Check', 'Credit Card', 'Cash') : @payment_methods = ['Credit Card']
    current_admin_user.admin? ? @payment.payment_method = 'Check' : @payment.payment_method = 'Credit Card'

    if @group_status == 'registration'
      @payment_types = 'Deposit', 'Other'
      @group = Registration.find(params[:group_id])
      @payment.payment_type = 'Deposit'
    else
      @payment_types = 'Deposit', 'Second', 'Final', 'Other'
      @group = ScheduledGroup.find(params[:group_id])
      @payment.payment_type = @group.likely_next_payment
      @payment.payment_amount = @group.likely_next_pay_amount
    end
    @page_title = "Make payment for group: #{@group.name}"
  end

  def create #payments for groups that are already scheduled
    if params[:payment_method] == 'Credit Card'
      process_cc_scheduled_payment(params[:group_id], params[:payment_amount], params[:amount_paid],
                                   params[:processing_charge], params[:payment_tracking_number], params[:payment_notes],
                                   params[:group_status])
    else
      process_cash_check_payment(params[:payment])
    end
  end

  def process_cash_check_payment(payment)
    @payment = Payment.new(payment)
    logger.debug @payment.inspect
    if (params[:group_status] == 'registration')
      group = Registration.find(params[:group_id])
      @payment.registration_id = group.id
    else
      group = ScheduledGroup.find(params[:group_id])
      @payment.scheduled_group_id = group.id
    end

    if @payment.valid?
      if @payment.payment_type == 'Second'
        group = ScheduledGroup.find(@payment.scheduled_group_id)
        group.second_payment_date = @payment.payment_date
        group.second_payment_total=group.current_total
        if group.save!
          log_payment_activity("Scheduled Group second payment date recorded: ", "#{@payment.payment_date} for #{group.name}")
        else
          flash[:error] = "Unable to updated group record."
        end
      end
      @payment.save!
      log_payment_activity("Payment by check", "$#{sprintf('%.2f', @payment.payment_amount)} paid for #{group.name}")
      UserMailer.payment_confirmation(group, params).deliver
      flash[:notice] = "Successful entry of new payment."
      redirect_to myssp_path(:id => group.liaison_id) and return
    else
      flash[:error] = "A problem occurred in creating this payment."
      @page_title = "Record payment for: #{group.name}"
      @group_status = params[:group_status]
      current_admin_user.admin? ? (@payment_methods = 'Check', 'Credit Card', 'Cash') : @payment_methods = ['Credit Card']

      if @group_status == 'registration'
        @payment_types = 'Deposit', 'Other'
        @group = Registration.find(params[:group_id])
      else
        @payment_types = 'Deposit', 'Second', 'Final', 'Other'
        @group = ScheduledGroup.find(params[:group_id])
      end
      @page_title = "Make payment for group: #{@group.name}"
      render "payment/new"
    end
  end

  #payments for groups that are already scheduled
  def process_cc_scheduled_payment(group_id, cc_payment_amount, cc_to_be_charged, cc_processing_charge, token, payment_comments,
      group_status)
    @group = ScheduledGroup.find(group_id)
    @payment_error_message = ''
    begin
      to_be_charged = (100 * cc_to_be_charged.to_f).to_i
      logger.debug to_be_charged
      charge = Stripe::Charge.create(
          :amount=> to_be_charged,
          :currency=>"usd",
          :card => token,
          :description => @group.name)
    rescue Stripe::InvalidRequestError => e
      @payment_error_message = "There has been a problem processing your credit card."
    rescue Stripe::CardError => e
      flash[:error] = @payment_error_message = e.message
    end

    if e
      render :partial => 'process_cc_scheduled_payment'
    else
      p = Payment.record_payment(group_id, cc_payment_amount, cc_processing_charge, "cc", "cc", payment_comments)
       if p
        log_payment_activity("CC Payment", "Group: #{@group.name} Fee amount: $#{sprintf('%.2f', cc_payment_amount.to_f)} Processing chg: $#{sprintf('%.2f', cc_processing_charge.to_f)}")
        UserMailer.cc_payment_confirmation(@group, p, cc_payment_amount, cc_processing_charge, payment_comments, group_status).deliver
        #flash[:notice] = "Successful entry of new payment."
        #redirect_to myssp_path(:id => @group.liaison_id)
      else
        @payment_error_message = "Unsuccessful save of payment record - please contact the SSP office."
      end
        render :partial => 'process_cc_scheduled_payment'
    end
  end

private
  def log_payment_activity(activity_type, activity_details)
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
