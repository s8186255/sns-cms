class ZonesController < ApplicationController
  before_filter :check_topic,:except=>[:show,:show_no_sign_in]

  layout "zone"

  def show
    #通过id或者title，获取topic实例，同时生成session数据，供其他action使用

    @current_topic=Topic.find_by_title(params[:title]) unless params[:title].blank?
    @current_topic=Topic.find_by_id(params[:id]) unless params[:id].blank?
    unless @current_topic.nil?
      session[:topic_id] =  @current_topic.id
      redirect_to :action=>:show_no_sign_in if current_user.nil?
      redirect_to :action=>:show_sign_in unless current_user.nil?
    else
      redirect_to '/'
    end
  end

  def show_no_sign_in
    @current_topic=Topic.find_by_id(session[:topic_id])
    #获取个性化css文件
    @css="index_zone.css"
    @n=5
    @m=5
    #判断
    case @current_topic.following_mode
    when TOPIC_FOLLOWING_MODE_PUBLIC
      show_normal_info_list
    when TOPIC_FOLLOWING_MODE_MEMBER
      redirect_to :action=>'show_sign_in'
    when TOPIC_FOLLOWING_MODE_PRIVATE
      render :template=>'/common/error_topic_is_private'
    end

  end

  def show_sign_in
    @n=5
    @m=5
    @current_topic=Topic.find_by_id(session[:topic_id])
    

    @css="index_zone.css"
    case @current_topic.following_mode
    when TOPIC_FOLLOWING_MODE_PUBLIC
      show_normal_info_list
    when TOPIC_FOLLOWING_MODE_MEMBER
      if @current_topic.creator?(current_user) or @current_topic.maintainer?(current_user) or @current_topic.follower?(current_user)
        show_normal_info_list
      else
        render :template=>'/common/error_topic_is_private_or_you_not_join'
      end
    when TOPIC_FOLLOWING_MODE_PRIVATE
      if @current_topic.creator?(current_user)
        show_normal_info_list
      else
        render :template=>'/common/error_topic_is_private'
      end
    end
  end
  #地盘内部搜索
  def search
    @current_topic = current_topic
    @topic_info_types = @current_topic.topic_info_types
    @css="index_zone.css"
    
    search_text = params[:search_text]
    @infos = @current_topic.search_info search_text
    render :template =>'/common/zone_info_list'
  end

  def show_info_details
    #    @info_id = params[:id]
    #    info_type_id = Info.find(@info_id).info_type_id
    #    @item_types = ItemType.find(:all,
    #      :conditions=>["info_type_id = ?",info_type_id])
    #    @item_type_ids =@item_types.collect{|x| x.id}
    #    @items = Item.find :all,
    #      :conditions=>["item_type_id IN(?) and info_id = ?",@item_type_ids,@info_id]
    #从my_constants中获取参数，为了传递到view。
    @css="index_zone.css"

    @current_topic = current_topic
    info_id = params[:id].to_i
    unless @current_topic.has_info?(info_id)
      redirect_to '/'
    else
      @info = Info.find params[:id]
      @items = @info.items_by_position_order

      if @info.content_type_ids.member? 11
        lat_lng= @info.item_of_content_type(11).lat_lng
        @map = GMap.new("map_div")
        @map.control_init(:large_map => true,:map_type => true)
        @map.center_zoom_init(@info.item_of_content_type(11).lat_lng,4)
        @map.overlay_init(GMarker.new(lat_lng,:title =>"India", :info_window =>"India"))
      end
      #用户浏览之后，增加该信息的浏览次数
      InfoCounter.add_view_count(@info.id)

      #显示评论，同时创建评论

      @comments = Comment.find(:all,
        :conditions=>["info_id = ? ",params[:id]])
      @comment = Comment.new
      render :template=>'/common/info_details'
    end
  end

  def list_info

    #获取页面传递过来的信息；
    topic_info_type_id = params[:id].to_i
    @current_topic = current_topic
    unless @current_topic.has_topic_info_type?(topic_info_type_id)
      flash[:notice]='信息类型有错误'
      redirect_to_topic_home(@current_topic.id)
    else
      @topic_info_type = TopicInfoType.find_by_id(topic_info_type_id)
      @css="index_zone.css"

      @nav_title = @topic_info_type.display_name_in_topic

      #准备显示的信息集合，这才是最重要的信息
      info_type_id = @topic_info_type.info_type_id
      @infos = @current_topic.infos_of_info_type(1,info_type_id)
      if @current_topic.infos_of_info_type(true,info_type_id).blank?
        render :template=>'/common/zone_info_list_is_null'
      else
        render :template=>'/common/zone_info_list'
      end
    end
  end

  private
  def current_topic
    Topic.find session[:topic_id]
  end

  def check_topic
    login_required unless current_topic.following_mode == TOPIC_FOLLOWING_MODE_PUBLIC
  end
  
  def show_normal_info_list

    @topic_info_types = @current_topic.topic_info_types
      
    @infos = @current_topic.infos_of_info_type(1,-1)

    #记录地盘的访问次数
    TopicCounter.add_view_count(@current_topic.id)
	  
    render :template=>'common/zone_info_list'
  end
  #返回地盘首页
  def redirect_to_topic_home(topic_id)
    redirect_to(:controller=>:zones,:action=>:show,:id=>topic_id)
  end
end
