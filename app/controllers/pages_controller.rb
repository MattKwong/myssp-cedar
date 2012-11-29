class PagesController < ApplicationController
  def home
    @page_title = "SSP Information Center"
    @title = "Welcome"
  end

  def contact
    @page_title = "SSP Information Center"
    @title = "Contact"
  end

  def about
    @page_title = "SSP Information Center"
    @title = "About"
  end

  def help
    @page_title = "SSP Information Center"
    @title = "Help"
  end

  def availability
    @page_title = "Current Availability"
    @title = "Availability"

    @matrices = Session.session_matrices("Availability", "Domestic Summer", 65, 50)
    #render :partial => 'availability_matrix'
    render :layout => nil
  end

end
