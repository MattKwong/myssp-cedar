class SspWebController < ActionController::Base
  rescue_from Timeout::Error, :with => :rescue_from_timeout
  include ReCaptcha::AppHelper

  def new_login_request
    @page_title = "Request a MySSP Login."
    @login_request = LoginRequest.new()
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
           flash[:success] = "Login request has been submitted. You will be contacted via email soon."
           log_activity("Login Request", "#{@login_request.first_name} #{@login_request.last_name} of #{@login_request.church_name}, #{@login_request.church_city}.")
           UserMailer.login_request(@login_request).deliver
           redirect_to :back
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
      a.activity_date = activity_date
      a.activity_type = activity_type
      a.activity_details = activity_details
      a.user_name = user_name
      unless a.save!
        flash[:error] = "Unknown problem occurred logging a transaction."
      end
  end
end