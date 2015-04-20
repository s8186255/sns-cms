# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include MyConstants
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  #  before_filter :configure_charsets
  #
  #    def configure_charsets
  ##       @headers["Content-Type"]="text/html;charset=utf-8"
  #       request.headers["Content-Type"]="text/html;charset=utf-8"
  #   end
  protected

  def info_of_user
    #我创建的地盘信息
    @my_c_topics = current_user.topics_created

    #列出我参与维护的topic，而不是我创建的（我创建的自然而然可以进行维护）中间的c表示maintaining。
    @my_m_topics = current_user.topics_maintaining

    #列出我加入的topic，中间的f表示following
    @my_f_topics = current_user.topics_following
  end

  def if_has_right_to_view_info(info_id,user_id)
    return true
    return false
  end
  #  protected
  #  def check_user
  #    if session[:user_id]
  #      @current_user = User.find_by_id session[:user_id]
  #    else
  #      redirect_to "/sessions/new"
  #      #redirect_to(:controller=>'sessions',:action=>'new')
  #    end
  #  end

  #  def find_item_type(info_type,position)
  #
  #    @item_type = ItemType.find(:first,
  #      :conditions=>["info_type_id=? AND position=?",info_type,position])
  #    return @item_type_id = @item_type.id
  #  end
    

end
