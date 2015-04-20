class TopicsController < ApplicationController
  before_filter :login_required
  before_filter :info_of_user
  layout "my"
  #@a = TRUE1
  #以下是与index具有相似功能的action
  #index
  #my_following_topics
  #get_hottest_topics
  #get_my_topics
  #get_myfollowing_topics
  #first
  
  # index显示现有的所有的topic
  def index
    #这个function id事先规划好，将需要验证的action，info_type_id找到。
    #然后将action的代码放在if...else...end语句中，进行授权判断。
    #另外关于info_type_id，可以查找哪些地方使用了获取info_type_id 参数的，
    #在使用该参数的地方，需要将function_id赋值语句加入，同时加入大的判断。
    #    function_id = 0
    #    #    if session[:function_ids].include?(function_id) != true
    #    unless current_user.id == 1
    #      @topics = Topic.find(:all,
    #        :conditions=>"status = 1")
    #    else
    #      @topics =Topic.find(:all,
    #        :conditions =>["creator_id = ? ",
    #          current_user.id])
    #    end
    #11月24日
    @topics = Info.find(params[:info_id]).topics
  end

  #get_hottest_topics列出追随人数最多的
  def get_hottest_topics
    @hottest_topics_5 = Topic.find(:all,:order=>'followings_count DESC',:conditions=>'followings_count > 0')
  end

  #列出我创建的topic，中间的c表示create
  def my_c_topics
    @topics = current_user.topics.find(:all,
      :conditions=>"status = 1")
  end

  #列出我维护的topic，中间的c表示maintaining
  def my_m_topics
    @topics = Topic.find_by_sql ['select * from topics where id in (select topic_id from maintainings where maintainer_id = ?) AND status = 1',current_user.id]
  end

  #列出我加入的topic，中间的f表示following
  def my_f_topics
    @topics = Topic.find_by_sql ['select * from topics where id in (select topic_id from followings where follower_id = ?) AND status = 1',current_user.id]
  end

  def first
    @hottest_topics_5 = Topic.find(:all,:order=>'followings_count DESC',
      :conditions=>'followings_count > 0',
      :limit=>5)
    @newest_infos = Info.find(:all,
      :order=>'updated_at DESC',
      :limit=>5)
    @myfollowing_topics = Following.find :all,
      :conditions=>["follower_id=?",current_user],
      :limit=>5
    #  @myfollowing_topics = current_user.followings
    @my_topics = Topic.find :all,
      :conditions=>["creator_id=?",current_user],
      :limit=>5
  end


  def new
    @topic = Topic.new
    #    @topic_types =TopicType.find :all
    @info_types = current_user.info_types
    #    @selected_info_type_ids = Array.new
    #    @my_teams = Team.find_by_creator_id current_user.id
    #@info_type_ids_of_topic = @topic.info_types.collect{|info_type| info_type.id}.uniq
    render :template=>'/my/topic_new'
  end

  def show_editor_and_follower_teams
    @team_options =Team.find(:all,:conditions=>['creator_id = ?',current_user.id]).
      collect{|team| "<option value='#{team.id}'>#{team.name}</option>"}
  end

  def show_editor_only_teams
    @team_options =Team.find(:all,:conditions=>['creator_id = ?',current_user.id]).
      collect{|team| "<option value='#{team.id}'>#{team.name}</option>"}
  end

  def show_follower_only_teams
    @team_options =Team.find(:all,:conditions=>['creator_id = ?',current_user.id]).
      collect{|team| "<option value='#{team.id}'>#{team.name}</option>"}
  end

  def create
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
      info_type_ids.each do |info_type_id|
        unless TopicInfoType.create :info_type_id=>info_type_id,:topic_id=>@topic.id
          flash[:notice]='创建失败'
        end
      end

      #创建topic_counter对象实例
      @topic.topic_counter = TopicCounter.create
      render :template=>'/common/test'
    else
      flash[:notice]='创建不成功，因为地盘的名称、昵称、类型不能为空'
    end
  end


  def create20091020
    #以下是创建topic实例所需的变量
    title=params[:title]
    description=params[:description]
    status = params[:status]
    if_permit_any_info_type = params[:if_permit_any_info_type].to_i
    topic_type_id = params[:topic_type].to_i

    #以下是team_topic所需的参数
    editor_team_id = params[:editor_team_id]
    follower_team_id = params[:follower_team_id]

    #创建topic实例
    @topic = Topic.create(:title=>title,
      :description=>description,
      :status => status,
      :if_permit_any_info_type =>if_permit_any_info_type,
      :topic_type_id=>topic_type_id,
      :creator_id=>current_user.id)

    #创建team_topic实例，采用两个if语句，保证任何一个条件生效，都会生成team_topic实例。
    #如果没有两个条件都失效，将不会生成team_topic实例
    if editor_team_id.nil? ==false
      TeamTopic.create :team_id=>editor_team_id,:topic_id=>@topic.id,:operation_id=>1
    end

    if follower_team_id.nil? ==false
      TeamTopic.create :team_id=>follower_team_id,:topic_id=>@topic.id,:operation_id=>2
    end

    #当用户选择“只是允许部分信息类型上传”，则需要建立topic_info_type实例
    if if_permit_any_info_type == 0
      selected_info_type_ids= params[:selected_info_type_ids]||[]
      selected_info_type_ids.each do |info_type_id|
        TopicInfoType.create(:info_type_id=>info_type_id,
          :topic_id=>@topic.id)
      end
    end

    #建立creator和topic的关系：就是创建following关系。
    Following.create(:follower_id=>current_user.id,
      :topic_id=>@topic.id,
      :creator_id=>current_user.id,
      :verified=>1)
  end

  def show_info_types
    @info_types = InfoType.find :all
    @selected_info_type_ids = Array.new
  end
  def permit_some_true
    @info_types = InfoType.find :all
    @selected_info_type_ids = Array.new
  end


  def show
    #定义两个来源方向
    @topic=Topic.find(params[:id]) unless params[:id].blank?
    render :template=>'my/topic_details'
    #    @topic=Topic.find_by_title(params[:title]) unless params[:title].blank?
    #
    #    if  @topic.nil?
    #      render :text=>'该地盘暂停使用'
    #    elsif @topic.following_mode ==  TOPIC_FOLLOWING_MODE_PUBLIC
    #      @infos_in_topic = Info.find_by_sql(['select * from infos where id IN (select info_id from topic_infos where topic_id =?)',@topic.id])
    #    end
  end
  #    if topic.followings.collect{|f| f.follower_id}.member?(current_user.id) or topic.following_mode == TOPIC_FOLLOWING_MODE_PUBLIC
  #      @topic =topic
  #
  #      #
  #      topic_id=topic.id
  #      @topic_info_types=TopicInfoType.find_all_by_topic_id topic_id
  #      infos_of_info_type=Array.new
  #      @topic_info_types.collect{|topic_info_type| topic_info_type.info_type_id}.each do |info_type_id|
  #        TopicInfo.find_all_by_topic_id(topic_id).collect{|topic_info| topic_info.info_id}.each do |info_id|
  #          infos_of_info_type[info_type_id] << Info.find(info_id) unless Info.find(info_id).nil?
  #        end
  #      end
  #    else
  #      render :text=>'hahahahahahahaha, 你还没有加入到这个地盘。',:layout=>'application'
  #    end


  def edit
    @topic=Topic.find params[:id]
    @used_info_types = @topic.info_types
    @remained_info_types = InfoType.find(:all)-@used_info_types
    @info_type_ids_of_topic = @topic.info_types.collect{|info_type| info_type.id}.uniq
    render :template=>'my/topic_edit'
  end

  def update
    @topic=Topic.find params[:id]
    @topic.update_attributes params[:topic]

    #修订topic于info_type之间的关系
    selected_info_type_ids = params[:info_type_id]
    selected_info_type_ids = selected_info_type_ids.collect{|info_type_id| info_type_id.to_i}
    @topic.update_topic_info_types(selected_info_type_ids)
    selected_info_type_ids.each do |info_type_id|
      TopicInfoType.find_by_topic_id_and_info_type_id(@topic.id,info_type_id).update_attributes :display_name_in_topic=>params["display_name_in_topic_#{info_type_id}"],
        :display_order_in_topic=>params["display_order_in_topic_#{info_type_id}"]
    end
  end

  def edit1020
    #在index.html.erb页面上，点击edit之后，采用link_to,向外输出topic id值
    #在edit方法中，获取topic_id
    @topic = Topic.find(params[:id])
    @info_types = InfoType.find :all
    @topic_types =TopicType.find :all
    @selected_info_type_ids = TopicInfoType.find(:all,:conditions=>['topic_id = ?',@topic.id]).collect{|x| x.info_type_id}

    @team_options =Team.find(:all,:conditions=>['creator_id = ?',current_user.id]).collect do |team|
      if TeamTopic.find(:first,:conditions=>{:topic_id=>@topic.id}).team_id == team.id
        "<option value='#{team.id}' selected>#{team.name}</option>"
      else
        "<option value='#{team.id}' >#{team.name}</option>"
      end
    end


  end

  def update_topic
    #使用edit-update这种顺序，可以直接将id值带上，所以不需要使用hidden_field页面控件传递数据
    #采用类似new-create的方式，只是主要采用update attribute方法，更新数据。

    #首先找到这个topic
    @topic= Topic.find(params[:id])

    title=params[:title]
    description=params[:description]
    if params[:status].nil?
      status = false
    else
      status = params[:status]
    end

    if_permit_any_info_type = params[:if_permit_any_info_type].to_i
    topic_type_id = params[:topic_type].to_i

    #以下是team_topic所需的参数
    editor_team_id = params[:editor_team_id]
    follower_team_id = params[:follower_team_id]

    #以下是更新topic属性
    @topic.update_attributes(:title=>title,
      :description=>description,
      :status => status,
      :if_permit_any_info_type =>if_permit_any_info_type)

    #以下是重建team_topic关系，当发生变化的时候，删除原来的team_topic记录，重建新的记录。
    unless @topic.topic_type_id ==topic_type_id
      if [5,6,7,8,9].member?(@topic.topic_type_id)
        #删除team_topic的关系
        @topic.team_topics.destroy_all
      end
      if [5,6,7,8,9].member?(topic_type_id)
        #再重新创建新的team_topic关系
        if editor_team_id.nil? ==false
          TeamTopic.create :team_id=>editor_team_id,:topic_id=>@topic.id,:operation_id=>1
        end

        if follower_team_id.nil? ==false
          TeamTopic.create :team_id=>follower_team_id,:topic_id=>@topic.id,:operation_id=>2
        end
      end
      @topic.update_attributes :topic_type_id=>topic_type_id

    end
    #重新建立topic与info_type的关系，已经有的，保留；没有的则删除。
    if if_permit_any_info_type == 0
      TopicInfoType.destroy_all(['topic_id = ?',@topic.id])
      @selected_info_type_ids= params[:selected_info_type_ids]
      @selected_info_type_ids.each do |info_type_id|
        TopicInfoType.create(:info_type_id=>info_type_id,
          :topic_id=>@topic.id)
      end
    end
    #与topic创建不同的是不进行follow关系的修改。
  end

  def destroy
    #同理从index页面通过点击获取id值，并创建topic对象
    @topic = Topic.find(params[:id])

    #将topic的status设置为2；
    @topic.update_attributes(:status => 2)
    
    #从followings中找到与这个topic相关的集合，并将其采用循环的方式删除。
    @followings = Following.find(:all,
      :conditions=>["topic_id=?",@topic.id])
    @followings.each{|x| x.destroy }

    #从topics_infos中找到与这个topic相关的集合，并将其采用循环的方式删除。
    @topic_infos = TopicInfo.find :all,
      :conditions=>["topic_id",@topic.id]
    @topic_infos.each{|x| x.destroy }

    redirect_to :action => 'get_my_topics'
  end

  def more_c_topics
    @my_c_topics = current_user.topics_created
  end

  def more_f_topics
    @topics = current_user.topics_following
    #render :template=>'/common/topic_list'
  end
  def more_m_topics
    @my_m_topics = current_user.topics_maintaining
  end

end