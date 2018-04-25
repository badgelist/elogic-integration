# Refer to https://github.com/thoughtbot/clearance/blob/master/app/controllers/clearance/users_controller.rb for underlying controller
class UsersController < Clearance::UsersController

  #=== CONSTANTS ===#

  PERMITTED_PARAMS = [:name, :email, :password]

  #=== ACTIONS ===#

  def index
    @users = User.all
  end
  
  def new
    @user = User.new
  end

  def create
    @user = user_from_params

    if @user.save
      flash[:success] = 'User successfully created.'
      redirect_to users_path
    else
      flash[:error] = 'There was a problem creating the user.'
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    
    filtered_user_params = user_params
    filtered_user_params.delete :password if (filtered_user_params[:password].blank?)

    if @user.update(filtered_user_params)
      flash[:success] = 'User successfully updated.'
      redirect_to users_path
    else
      flash[:error] = 'There was a problem updating the user.'
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      redirect_to users_path
      flash[:success] = 'User successfully deleted.'
    else
      flash[:error] = 'There was a problem deleting the user.'
      render :edit
    end
  end

private

  def user_params
    params.require(:user).permit(PERMITTED_PARAMS)
  end

  # This overrides the standard method (which prevents signed in users from being able to create new users)
  def redirect_signed_in_users
    return false
  end

end