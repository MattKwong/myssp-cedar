class SupportersController < ApplicationController

  def new
    @page_title = "Please Complete the SSP Supporter Survey."
    @supporter = Supporter.new()
  end

  def create
    @supporter = Supporter.new(params[:supporter])
    @captcha_error = false

    if !validate_recap(params, @supporter.errors)
      flash[:error] = "Please re-enter the challange words in the Captcha dialog box."
      @page_title = "Please Complete the SSP Supporter Survey."
      @captcha_error = true
      render 'new'
    else if @supporter.save
        flash[:success] = "Supporter information successfully created."
        @supporter.destroy
        redirect_to 'http://www.sierraserviceproject.org/supportersurvey_thankyou.html'
      else
        flash[:error] = "Errors prevented participant entry from being saved."
        @page_title = "Please Complete the SSP Supporter Survey."
        render 'new'
      end
    end
  end

end
