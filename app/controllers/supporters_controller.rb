class SupportersController < ApplicationController

  def new
    @page_title = "Please Complete the SSP Supporter Survey."
    @supporter = Supporter.new()
  end

  def create
    @supporter = Supporter.new(params[:supporter])

    if validate_recap(params, @supporter.errors) && @supporter.save
      flash[:success] = "Supporter information successfully created."
      redirect_to 'http://www.sierraserviceproject.org'
    else
      flash[:error] = "Errors prevented participant entry from being saved."
      @page_title = "Please Complete the SSP Supporter Survey."
      render 'new'
    end
  end

end
