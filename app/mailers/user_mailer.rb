class UserMailer < ActionMailer::Base
  default from: "meghan.osborn@sierraserviceproject.org"
  default cc: "admin@sierraserviceproject.org"

  def registration_confirmation(registration, params)
    registration_data(registration, params)
    mail(:to => @registration.liaison.email1, :subject => "SSP Group Registration Confirmation")
  end

  def registration_change_confirmation(registration, params)
    registration_data(registration, params)
    mail(:to => @registration.liaison.email1, :subject => "SSP Group Registration Change Confirmation")
  end

  def registration_data(registration, params)
    @registration = registration
    @params = params
    @choices = Array.new
    @choices << registration.request1 << registration.request2 << registration.request3 << registration.request4 <<
        registration.request5 << registration.request6 << registration.request7 << registration.request8 <<
        registration.request9 << registration.request9

  end
  def payment_confirmation(group, params)
    @group = group
    @params = params
    #@choices = Array.new
    #@choices << registration.request1 << registration.request2 << registration.request3 << registration.request4 <<
    #    registration.request5 << registration.request6 << registration.request7 << registration.request8 <<
    #    registration.request9 << registration.request9
    mail(:to => group.liaison.email1, :subject => "Payment Confirmation")
  end

  def cc_payment_confirmation(group, p, cc_payment_amount, cc_processing_charge, payment_comments, group_status)
    @group = group
    @payment = p
    @cc_payment_amount = cc_payment_amount
    @cc_processing_charge = cc_processing_charge
    @cc_payment_comments = payment_comments
    @group_status = group_status
    mail(:to => group.liaison.email1, :subject => "Credit Card Payment Confirmation")
  end

  def schedule_confirmation(group)
    @group = group
    mail(:to => @group.liaison.email1, :subject => "2013 SSP Placement Confirmation for your #{@group.session_type.name} Group")
  end
end
