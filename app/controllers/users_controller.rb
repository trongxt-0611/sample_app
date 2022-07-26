class UsersController < ApplicationController
  before_action :find_user, except: [:index, :new, :create]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @pagy, @users = pagy(User.all, items: Settings.pagy.items)
  end

  def show
    @pagy, @microposts = pagy(@user.microposts.newest,
                              items: Settings.pagy.items)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t ".check_email"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = t ".profile_update_sucess"
      redirect_to @user
    else
      flash[:danger] = t ".profile_update_failed"
      render :edit
    end
  end

  def destroy
    if @user.admin?
      flash[:danger] = t ".delete_admin_error"
    elsif @user.destroy
      flash[:success] = t ".user_deleted_success"
    else
      flash[:danger] = t ".user_deleted_failed"
    end
    redirect_to users_url
  end

  def following
    @title = t ".following"
    @pagy, @users = pagy(@user.following)
    render "show_follow"
  end

  def followers
    @title = t ".followers"
    @user = User.find(params[:id])
    @pagy, @users = pagy(@user.followers)
    render "show_follow"
  end

  private

  def correct_user
    return if current_user? @user

    flash[:danger] = t ".no_permission"
    redirect_to root_url
  end

  def admin_user
    return if current_user.admin?

    flash[:danger] = t ".no_permission"
    redirect_to users_url
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".show.user_not_found"
    redirect_to signup_path
  end

  def user_params
    params.require(:user)
          .permit(:name, :email, :password, :password_confirmation)
  end
end
