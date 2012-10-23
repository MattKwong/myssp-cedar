class SessionController < ApplicationController

  def program_session
    @requests = Registration.find_all_by_request1(params[:id])
    session = Session.find(params[:id])
    @session_week = Period.find(session.period.id).name
    @session_site = Site.find(session.site_id).name
  end

end