class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  layout "login"
  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/my')
      flash[:notice] = "#{current_user.login}成功登录" if flash[:notice].nil?
    else
      flash[:notice] = "登录不成功"
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    flash[:notice] = "你已成功注销"
    reset_session
    
    redirect_back_or_default('/')
  end

#  def create
#    #使用输入信息在库中查找，生成一个对象。
#    @current_user = User.find_by_login_and_password(params[:login], params[:password])
#    #如果找到了，则返回一个值，如果找不到，则返回nil
#
#    unless @current_user.nil?
#      #将用户的id置为session值，便于全程使用
#      session[:user_id] = @current_user.id
#      #在找到的情况下，从UserFunction中找到这个用户已经具有的权限，放到数组中，这样非常节省内存的哦。
#      session[:function_ids]=UserFunction.find(:all,
#        :conditions=>["user_id = ? AND status = ?",
#          @current_user.id,1]).collect{|user_function| user_function.function_id }
#      redirect_to :controller=>'topics',:action=>'first'
#    else
#      render :action => 'new'
#    end
#  end

#  def destroy
#    session[:user_id] = @current_user = nil
#    #  redirect_to :controller=>'topics',:action=>new
#  end

end
