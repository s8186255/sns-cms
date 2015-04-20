class TopicInfosController < ApplicationController
  before_filter :login_required

  layout "my"
  def index
    #从topics中找到tipic id，再到topic_infos中找到符合条件的记录
    #查找申请加入topic的请求。
    @topic = Topic.find params[:id]
    @topic_infos=@topic.infos_for_verify
    render :template=>'/common/relation_list'
  end

  def new
    ##################################
    #准备topic列表资源，提供new.html.erb使用
    #条件如下：
    # 首先是将topic列表必须是用户已经在maintainings中建立了关系的topic；
    # 然后将topic分为两类：自己创建的，别人创建的
    # 第三只能选择加入一个topic。
    ##################################
    @topic_info = TopicInfo.new
    @topics = Topic.find_by_sql ['select * from topics where id IN (select topic_id from maintainings where maintainer_id = ?)',current_user.id]
    @my_topics = Array.new
    @other_topics = Array.new

    @info_id = params[:info_id]
    unless @topics.nil?
      @topics.each do |topic|
        if topic.creator_id==current_user.id
          @my_topics << topic
        else 
          @other_topics << topic
        end
      end
    end
  end

  def create
    ##################################
    #建立info和topic的关系
    #准备如下参数：
    # topic_id
    # info_id
    # verified
    # creator_id
    # affirmant_id
    ##################################
    topic_info = params[:topic_info]
    topic_id = topic_info["topic_id"]
    info_id =  topic_info["info_id"]

    topic = Topic.find(topic_id)
    if TopicInfo.find(:all,:conditions=>['info_id=? AND topic_id =?',info_id,topic_id]).blank?
      if topic.if_verify_info == TOPIC_IF_VERIFY_INFO_NO
        verified = true
        affirmant_id = topic.creator_id
      elsif topic.if_verify_info == TOPIC_IF_VERIFY_INFO_YES
        verified = false
      end

      topic.topic_infos.create(:info_id=>info_id,
        :verified=>verified,
        :creator_id =>current_user.id,
        :affirmant_id =>affirmant_id
      )
    else
      render :text=>'以前发布过'
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  def delete
  end

end
