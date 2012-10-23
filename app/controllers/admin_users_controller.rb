class AdminUsersController < Admin::AdminUsersController
  load_and_authorize_resource

  def new
    super
  end

  def update
    super
  end

  def soft_delete
    logger.debug 'In AdminUsersController'
  #
  end

  def create

    if @user.staff?
      @user.skip_confirmation!
    end
    if @user.save
      flash[:notice] = "Successfully created user"
      redirect_to root_path
    else
      render :action => 'new'
    end
  end


end
