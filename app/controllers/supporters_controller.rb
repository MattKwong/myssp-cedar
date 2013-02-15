class SupportersController < ApplicationController

  def new
    @page_title = "Registering as an SSP supporter."
    @supporter = Supporter.new()
  end

  def create
    @supporter = Supporter.new(params[:supporter])

    if @supporter.save
      flash[:success] = "Supporter information successfully created."
      redirect_to 'http://www.sierraserviceproject.org'
    else
      flash[:error] = "Errors prevented participant entry from being saved."
      @page_title = "Registering as an SSP supporter."
      render 'new'
    end
  end

end
