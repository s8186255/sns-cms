class MyController < ApplicationController
  before_filter :login_required,:except=>[:index_no_sign_in]
  before_filter :info_of_user

  layout "my"

  def index
    #登录者follow的地盘列表
    #    @topic_list_desc = '我追随的地盘'
    #    @topics = current_user.topics_following
    #    @current_user_and_topic_relation = 2

    #登录者follow的地盘的信息；
    @infos = current_user.infos_in_following_topics
    @nav_description = '我关心的信息'
    render :template=>'/my/info_list'

  end

  #####
  def list_infos_of_topic
    topic =Topic.find_by_id params[:id].to_i unless params[:id].nil?
    session[:my_topic_id] = topic.id
    if !topic.nil? and topic_id_is_validate?(topic)
      @infos = topic.infos(1,-1)
      @info_list_type = 0
      @nav_description = '【'+topic.title.to_s+'】'+'地盘中的信息:'
      render :template=>'my/info_list'
    else
      flash[:notic]='无此地盘信息'
      redirect_to '/'
    end
  end

  def info_detail
    #    @info_id = params[:id]
    #    info_type_id = Info.find(@info_id).info_type_id
    #    @item_types = ItemType.find(:all,
    #      :conditions=>["info_type_id = ?",info_type_id])
    #    @item_type_ids =@item_types.collect{|x| x.id}
    #    @items = Item.find :all,
    #      :conditions=>["item_type_id IN(?) and info_id = ?",@item_type_ids,@info_id]
    #从my_constants中获取参数，为了传递到view。
    #    unless params[:topic_id].blank?
    #      @topic = Topic.find params[:topic_id]
    #      @topic_info_types = @topic.topic_info_types
    #    end
    begin
      @info = Info.find params[:id]
    rescue ActiveRecord::RecordNotFound
      flash[:notice]='你查看信息的信息不存在'
      redirect_to '/my'
    else
      if @info.viewed_by?(current_user)
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
        #及时清除session
    
        #
        render :template=>'/common/info_details'
      else
        flash[:notice]='你无权查看此信息'
        redirect_to '/my'
      end
    end
  end

  def edit_info
    ###################################################
    # 1.获取info id之后，创建@info对象实例
    # 2.获取@info的@items集合。
    # 3.然后将items集合中的单项显示出来即可
    # 4.显示info和topic之间的关系
    # 5.
    ###################################################
    #从my_constants中获取参数，为了传递到view。
    @item_is_attachment = ITEM_IS_ATTACHMENT
    @item_is_common = ITEM_IS_COMMON
    @item_is_rich_text = ITEM_IS_RICH_TEXT
    @item_is_geo = ITEM_IS_GEO

    begin
      @info = Info.find params[:id]
    rescue
      flash[:notice]='你修改的信息不存在'
      redirect_to '/my'
      #如果没有edit的权限，直接返回到my的首页
    else
      if @info.edit_by?(current_user)

        #调用info的实例方法
        @item_types = @info.item_types
        @items = @info.items_by_position_order

        #如果该信息的item中有地图信息，准备地图数据
        if @info.content_type_ids.member? 11

          @map = GMap.new("map_div")
          @map.control_init(:large_map => true,:map_type => true)
          @map.center_zoom_init(@info.item_of_content_type(11).lat_lng,4)
          @map.overlay_init(GMarker.new(@info.item_of_content_type(11).lat_lng,:title =>"India", :info_window =>"India"))
          @map.record_init @map.on_click("function(overlay,point){updateLocation(point)}")

        else
          if @info.info_type.related_content_types('id').member? 11
            @map = GMap.new("map_div")
            @map.control_init(:large_map => true,:map_type => true)
            @map.center_zoom_init([22.792388,79.497070],4)
            @map.overlay_init(GMarker.new([22.792388,79.497070],:title =>"India", :info_window =>"India"))
            @map.record_init @map.on_click("function(overlay,point){updateLocation(point)}")
          end
        end



        @available_item_types = @info.blank_item_types
        #列出“我维护的地盘”
        @maintainable_topics = current_user.topics_maintaining
        @info_related_topics = @info.topics
      else
        flash[:notice]='你无权对此信息进行修改'
        redirect_to '/my'
      end
    end
  end

  def update_info
    #1.找到info 对象，依据三个参数:if_commented、、info_type_id
    @info=Info.find params[:id]
    @info.update_attributes :if_commented=>params[:info][:if_commented] unless params[:info].nil?

    extra_condition_id = params[:extra_condition_id]||[]

    #进行info中的item内容更新；
    @info.items.each do |item|
      item_value = params["value_of_#{item.item_type.id}"]
      item.update_item(item.item_type,item_value,@info.id,params[:latitude],params[:longitude])
    end

    #新增item,利用item_type集合，创建每一个item对象实例
    @info.blank_item_types.each do |item_type|
      item_value = params["value_of_#{item_type.id}"]
      Item.create_item(item_type,item_value,@info.id,params[:latitude],params[:longitude]) unless item_value.blank?
    end

    #4.创建topic_info对象（集合）

    if params[:topic_id].nil?
      topic_ids = params[:selected_topics]||[]
      info_id = @info.id
      topic_ids.each{|topic_id| TopicInfo.create_topic_info(topic_id, info_id,current_user.id)}
    else
      TopicInfo.create_topic_info(params[:topic_id], info_id,current_user.id)
    end


    #修订时间
    @info.update_attributes :updated_at=>Time.now
    #返回本类信息首页
    redirect_to :action=>:index
  end
  
  def drop_info
    begin
      @info = Info.find(params[:id])
    rescue
      flash[:notice]='你要删除的信息不存在'
      redirect_to '/my'
    else
      if @info.edit_by?(current_user)
        @info.destroy
        redirect_to :back
      else
        flash[:notice]='你无权对此信息进行修改'
        redirect_to '/my'
      end
    end
  end

  #创建新的信息，由new_info和create_info组成。
  def new_info
    #info_type表明信息应用工具
    info_type_id = params[:id].to_i
    begin
      @info_type = InfoType.find info_type_id
      #@topic_id将为new.html.erb提供数据，提供的方式按照hidden_field。
      unless params[:topic_id].blank?
        @topic_id = params[:topic_id]
        topic =Topic.find @topic_id
      end
    rescue
      flash[:notice]='你要新建的信息类型或者地盘不存在'
      redirect_to '/my'
    else
      #从my_constants中获取参数，为了传递到view。
      @item_is_attachment = ITEM_IS_ATTACHMENT
      @item_is_common = ITEM_IS_COMMON
      @item_is_rich_text = ITEM_IS_RICH_TEXT
      @item_is_geo = ITEM_IS_GEO
      unless topic.nil?
        if (topic.creator?(current_user) or topic.maintainer?(current_user)) and topic.has_info_type?(info_type_id)


          #item_types参数为了输入具体的信息条目做好数据准备。
          @item_types = @info_type.item_types

          #准备item_types中的content_type_id是GEO的地图信息的
          if @info_type.related_content_types('id').member? 11
            #创建初始化的地图，这里可以结合user所在的地点，进行操作，如果是空，则缺省到国家。
            @map = GMap.new("map_div")
            @map.control_init(:large_map => true,:map_type => true)
            @map.center_zoom_init([22.792388,79.497070],4)
            @map.overlay_init(GMarker.new([22.792388,79.497070],:title =>"India", :info_window =>"India"))
            @map.record_init @map.on_click("function(overlay,point){updateLocation(point)}")
          end

          #列出的topic符合如下条件：

          @maintainable_topics = @info_type.topics_avaliable_for(current_user.id)
          render :template=>'infos/new'
        else
          redirect_to '/my'
        end
      else
        if @info_type.created_by?(current_user)
          #item_types参数为了输入具体的信息条目做好数据准备。
          @item_types = @info_type.item_types

          #准备item_types中的content_type_id是GEO的地图信息的
          if @info_type.related_content_types('id').member? 11
            #创建初始化的地图，这里可以结合user所在的地点，进行操作，如果是空，则缺省到国家。
            @map = GMap.new("map_div")
            @map.control_init(:large_map => true,:map_type => true)
            @map.center_zoom_init([22.792388,79.497070],4)
            @map.overlay_init(GMarker.new([22.792388,79.497070],:title =>"India", :info_window =>"India"))
            @map.record_init @map.on_click("function(overlay,point){updateLocation(point)}")
          end

          #列出的topic符合如下条件：

          @maintainable_topics = @info_type.topics_avaliable_for(current_user.id)
          render :template=>'infos/new'
        else
          redirect_to '/my'
        end
      end
    end
  end

  def create_info
    #################################
    #创建一个info实体需要做如下3件事：
    #1.创建info对象（单数）；
    #2.创建items对象（集合）；
    #3.创建items对应的attachment（集合）；
    #4.创建topic_info对象（集合）
    #5.更新topic_statistic记录
    #################################
    #1.创建info 对象，依据三个参数:if_commented、、info_type_id
    @info_type = InfoType.find params[:info_type_id].to_i

    @info=Info.create(:if_commented=>params[:if_commented],
      :creator_id=>current_user.id,
      :info_type_id=>@info_type.id)

    extra_condition_id = params[:extra_condition_id]||[]

    #利用item_type集合，创建每一个item对象实例
    item_types =@info_type.item_types
    item_types.each do |item_type|
      item_value = params["value_of_#{item_type.id}"]
      Item.create_item(item_type,item_value,@info.id,params[:latitude],params[:longitude])
    end

    #4.创建topic_info对象（集合）,如果后面有topic_id，说明是从地盘操作这个途径进行操作；如果后面没有topic_id，则说明是从信息工具而来。

    if params[:topic_id].nil?
      topic_ids = params[:selected_topics]||[]
      topic_ids.each{|topic_id| TopicInfo.create_topic_info(topic_id,@info.id,current_user.id)}
    else
      TopicInfo.create_topic_info(params[:topic_id], @info.id,current_user.id)
    end
    render :template=>'common/success'
  end
  #####
  #我创建的地盘
  def new_topic
    @topic = Topic.new
    #    @topic_types =TopicType.find :all
    @info_types = current_user.info_types
    #    @selected_info_type_ids = Array.new
    #    @my_teams = Team.find_by_creator_id current_user.id
    #@info_type_ids_of_topic = @topic.info_types.collect{|info_type| info_type.id}.uniq
    render :template=>'/my/topic_new'

  end

  def create_topic
    ##################################
    #1.创建topic对象实例
    #2.创建creator和topic之间是following关系的对象实例
    #3.创建creator和topic之间是maintaining关系的maintaining对象实例
    #4.创建topic下可用的应用
    ##################################
    #创建topic对应的图片对象实例：

    #创建topic
    @topic = Topic.new(params[:topic])
    if @topic.save
      @topic.update_attributes :creator_id=>current_user.id
      @topic.topic_avatar = TopicAvatar.create(:uploaded_data=>params["topic_avatar"])

      #创建topic下可用的应用
      info_type_ids = params[:info_type_id]
      n=1
      info_type_ids.each do |info_type_id|
        TopicInfoType.create :topic_id=>@topic.id,
          :info_type_id=>info_type_id,
          #下面的语句用于人为调整信息工具，目前view层的顺序调整上不完善
        #:display_order_in_topic=>params["display_order_in_topic_#{info_type_id}"],
        :display_order_in_topic=>n,
          :display_name_in_topic=>params["display_name_in_topic_#{info_type_id}"]
        n+=1
      end

      #创建topic_counter对象实例
      @topic.topic_counter = TopicCounter.create
      #render :template=>'/common/test'
      redirect_to :action=>:list_topics,:id=>1
    else
      flash[:notice]='创建不成功，因为地盘的名称、昵称、类型不能为空'
      render :template=>'common/error'
    end

  end

  def list_topics
    operation = params[:id].to_i
    case operation
    when 1
      @topic_list_desc = '我创建的地盘'
      @topics = current_user.topics_created
      @current_user_and_topic_relation = 0
      @nav_description='我创建的地盘'
      render :template=>'/my/topic_list'
    when 2
      @topic_list_desc = '我维护的地盘'
      @topics = current_user.topics_maintaining
      @current_user_and_topic_relation = 1
      @nav_description='我维护的地盘'
      render :template=>'/my/topic_list'
    when 3
      @topic_list_desc = '我追随的地盘'
      @topics = current_user.topics_following
      @current_user_and_topic_relation = 2
      @nav_description='我加入的地盘'
      render :template=>'/my/topic_list'
    else
      render :template=>'/common/error'
    end
  end
  
  #修订topic
  def edit_topic
    begin
      @topic=Topic.find params[:id]
    rescue
      flash[:notice]='你要修改的地盘不存在'
      redirect_to '/my'
    else
      @used_info_types = @topic.info_types
      @remained_info_types = InfoType.find(:all)-@used_info_types
      @info_type_ids_of_topic = @topic.info_types.collect{|info_type| info_type.id}.uniq
      render :template=>'my/topic_edit'
    end
  end
  #修订topic
  def update_topic
    @topic=Topic.find params[:id]
    @topic.update_attributes params[:topic]
    @topic.update_avatar(params["topic_avatar"])
    #修订topic于info_type之间的关系
    selected_info_type_ids = params[:info_type_id]||[]
    unless selected_info_type_ids.nil?  #如果不为空，也就是用户选择了信息工具。
      selected_info_type_ids = selected_info_type_ids.collect{|info_type_id| info_type_id.to_i}

      @topic.update_topic_info_types(selected_info_type_ids)
      @topic.topic_info_types.each do |topic_info_type|
        topic_info_type.update_attributes :display_name_in_topic=>params["display_name_in_topic_#{topic_info_type.info_type_id}"]
      end
    end
    redirect_to :action=>:list_topics,:id=>1
  end

  #信息列表
  def my_info
    info_type = InfoType.find(params[:id])
    @infos = current_user.infos_of_info_type(info_type.id)
    @nav_description = info_type.cloud_tool_name
    render :template=>'my/info_list'
  end

  #地盘信息列表
  def infos_of_topic
    begin
      topic =Topic.find params[:id]
    rescue
      flash[:notice]='你要查看的信息列表不存在'
      redirect_to '/my'
    else
      @infos = topic.infos(1,-1)
      @info_list_type = 0
      @nav_description = '【'+topic.title.to_s+'】'+'地盘中的信息:'
      render :template=>'my/info_list'
    end
  end

  #显示topic的细节
  def topic_details
    begin
      @topic=Topic.find(params[:id])
    rescue
      flash[:notice]='你无权查看此地盘'
      redirect_to '/my'
    else
      redirect_to '/my'
      render :template=>'my/topic_details'
    end
  end

  #搜索地盘或者信息
  def search
    search_text = params[:search_text]
    unless search_text.blank?
      if params[:commit] == '搜地盘'
        @topics = Topic.search search_text
        render :template =>'/my/search_topic_list'
      elsif params[:commit] == '搜信息'
        @infos = Info.search search_text
        render :template =>'/my/search_info_list'
      end
    else
      render :template=>'/error/no_search_txt'
    end
  end

  #设置地盘维护帮手
  def list_helpers_of_topic
    begin
      @topic = Topic.find params[:id]
    rescue
      flash[:notice]='该地盘不存在'
      redirect_to '/my'
    else
      if @topic.creator?(current_user)
        render :template=>'/my/list_helpers_of_topic'
      else
        flash[:notice]='你无权查看此地盘信息'
        redirect_to '/my'
      end
    end
  end

  
  def config_helpers_of_topic
    #从前一个页面获取用户选择的帮手的id，如果选择了则返回数组；如果没有选择，则返回nil
    maintainer_ids = params[:maintainer_ids]
    @topic = Topic.find params[:topic_id]
    if @topic.creator?(current_user)
      @topic.update_helpers(maintainer_ids)
      flash[:notice]='创建成功'
      redirect_to '/my'
    else
      flash[:notice]='你无权创建'
      redirect_to '/my'
    end
  end

  private
  def topic_id_is_validate?(topic)
    topic.creator?(current_user) or topic.follower?(current_user) or topic.maintainer?(current_user)
  end

end
