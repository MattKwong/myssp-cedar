class SupportersController < ApplicationController

  def new
    @page_title = "Thank you for registering as an SSP supporter."
    @supporter = Supporter.new()
  end

  def create
    supporter = Supporter.new(params[:supporter])
    if supporter.valid?
      supporter.save!
      flash[:success] = "Supporter information successfully created."
      redirect_to :back
    else
      @page_title = "Thank you for registering as an SSP supporter."
      render :new
    end
  end
end
