class User3sController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  

  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user3 = User3.new(params[:user3])
    @user3.save
    if @user3.errors.empty?
      self.current_user3 = @user3
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end

  def activate
    self.current_user3 = params[:activation_code].blank? ? false : User3.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user3.active?
      current_user3.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end

end
