class SspWebController < ActionController::Base
  rescue_from Timeout::Error, :with => :rescue_from_timeout
  include ReCaptcha::AppHelper
  layout 'admin_layout'

  def new_login_request
    @page_title = "Request a MySSP Login."
    @login_request = LoginRequest.new()
  end

  def thank_you
    @page_title = "Thank You for Submitting a Login Request"
  end

  def create_login_request
    @login_request = LoginRequest.new(params[:login_requests])
    @captcha_error = false

    if !validate_recap(params, @login_request.errors)
      flash[:error] = "Please re-enter the challenge words in the Captcha dialog box."
      @page_title = "Request a MySSP Login."
      @captcha_error = true
      render 'new_login_request'
    else if @login_request.save
           flash[:notice] = "Login request has been submitted. You will be contacted via email soon."
           log_activity(Date.today, "Login Request",
                        "#{params[:login_request][:first_name]} #{params[:login_request][:last_name]} of #{params[:login_request][:church_name]}, #{params[:login_request][:church_city]}.")
           UserMailer.login_request(@login_request).deliver
           redirect_to '/thank_you'
         else
           flash[:error] = "Errors prevented participant entry from being saved."
           @page_title = "Request a MySSP Login."
           render 'new_login_request'
         end
    end
  end

  private

  def log_activity(date, type, description)
      a = Activity.new
      a.activity_date = date
      a.activity_type = type
      a.activity_details = description
      a.user_name = 'Guest'
      a.user_id = 1
      logger.debug a.inspect
      unless a.save!
        flash[:error] = "Unknown problem occurred logging a transaction."
      end
  end
end