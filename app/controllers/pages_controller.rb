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

    @matrices = Session.session_matrices("Summer Domestic", 65, 50, 40)
    #render :partial => 'availability_matrix'
    render :layout => nil
  end
  def availability_other
    @page_title = "Current Availability"
    @title = "Availability"

    @matrices = Session.session_matrices("Other", 65, 50, 40)
    #render :partial => 'availability_matrix'
    render :layout => nil
  end

end
