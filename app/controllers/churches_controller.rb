require 'csv'

class ChurchesController < ApplicationController
  load_and_authorize_resource
    layout 'admin_layout'

  def edit
    @page_title = "Edit Church Information: #{@church.name}"
  end

  def update

    if @church.update_attributes(params[:church])
      flash[:success] = "Successful update of church information"
      redirect_to myssp_path(Liaison.find_by_church_id(@church.id).id)
    else
      flash[:error] = "Update of church information failed."
      render 'edit'
    end

  end

  def create
    if @church.save
      flash[:notice] = "New church record has been successfully created."
      church_id = @church
      redirect_to process_login_request_path(params[:request_id], :church_id => church_id)
    else
      flash[:error] = "Errors prevented this record from being created."
      @login_request = LoginRequest.find(params[:request_id])
      #@church = Church.new
      render '/login_requests/create_church'
    end

  end
end


