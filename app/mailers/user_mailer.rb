class UserMailer < ActionMailer::Base
  default from: "meghan.osborn@sierraserviceproject.org"
  default cc: "admin@sierraserviceproject.org"

  def registration_confirmation(registration, params)
    @registration = registration
    @params = params
    @choices = Array.new
    @choices << registration.request1 << registration.request2 << registration.request3 << registration.request4 <<
        registration.request5 << registration.request6 << registration.request7 << registration.request8 <<
        registration.request9 << registration.request9
    logger.debug @choices.inspect
    #@url  = "http://example.com/login"
    mail(:to => @registration.liaison.email1, :subject => "SSP Group Registration Confirmation")
  end
end
