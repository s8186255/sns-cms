# This controller handles the login/logout function of the site.  
class Session3sController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
  end

  def create
    self.current_user3 = User3.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user3.remember_me unless current_user3.remember_token?
        cookies[:auth_token] = { :value => self.current_user3.remember_token , :expires => self.current_user3.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      render :action => 'new'
    end
  end

  def destroy
    self.current_user3.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
end
