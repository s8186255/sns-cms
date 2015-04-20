class FollowingsController < ApplicationController
  before_filter :login_required
  before_filter :info_of_user
  layout "my"

  def index
    #查找申请加入topic的请求。
    begin
      @topic = Topic.find params[:id]
    rescue
      flash[:notice] = '地盘不存在'
      redirect_to :controller=>:my
    else
      if @topic.maintainer?(current_user) or @topic.creator?(current_user)
        @followings=@topic.followings_for_verify
        render :template=>'/common/relation_list'
      else
        flash[:notice] = '无权操作'
        redirect_to :controller=>:my
      end

    end
  end


  def new
    #######################
    #创建一个对象实例，供视图使用
    #######################
    @following = Following.new
  end

  def create
    #######################
    #创建following对象实例
    # follower_id
    # topic_id
    # verified
    # creator_id
    #######################
    topic_id = params[:topic_id]
    topic = Topic.find(topic_id)
    if Following.find(:all,:conditions=>['follower_id=? AND topic_id =?',current_user.id,topic_id]).blank?
      if topic.following_mode == TOPIC_FOLLOWING_MODE_PUBLIC
        verified = true
        affirmant_id = topic.creator_id
      elsif topic.following_mode == TOPIC_FOLLOWING_MODE_MEMBER
        verified = false
      elsif topic.following_mode == TOPIC_FOLLOWING_MODE_PRIVATE
        verified = true
        affirmant_id = topic.creator_id
      end

      topic.followings.create(:follower_id=>current_user.id,
        :verified=>verified,
        :creator_id =>current_user.id,
        :affirmant_id =>affirmant_id
      )
    else
      render :text=>'已经建立follow关系'
    end
  end

  def new1020

    #    @all_topics_status_is_open = Topic.find(:all,:conditions=>["status = 1 AND topic_type_id IN ?",[2,3]])
    #    @all_topics_followable_is_on = @all_topics_status_is_open
    #    @my_following_topic_ids = Following.find(:all,
    #      :conditions=> ["follower_id=?",current_user]).collect{|x| x.topic_id}.uniq
    #    @optional_topic_ids = @all_topic_ids - @my_following_topic_ids
    #    @optional_topics = Topic.find @optional_topic_ids

    #public_optional_topics
    @public_optional_topics = Topic.find :all,:conditions=>['topic_type_id IN(?)',PUBLIC_OPTIONAL_TOPIC_IDS]

    #member_optional_topics
    @member_optional_team_topics = TeamTopic.find :all,:group=>'team_id',:conditions=>{
      :team_id=>TeamUser.find(:all,:conditions=>{:user_id=>current_user.id}).collect { |team_user| team_user.team_id  }.uniq,
      :operation_id=>FOLLOW_OPERATION_ID
    }
  end

  def create1020
    #如下是准备创建following所需的参数,其中模型所需的
    #follower_id,creator_id的值都是current_user
    #verified则是根据topic的if_verify_follower.
    #topic_id来自选择的topic

   
    @picked_topics = Topic.find(params[:picked_topics]||[])

    @picked_topics.each do |topic|
      if TOPIC_TYPE_IDS_NEED_VERIFY.member? topic.topic_type_id
        verified = VERIFIED_IS_FALSE
      else
        verified = VERIFIED_IS_TRUE
      end
      Following.create(:follower_id=>current_user.id,
        :topic_id=>topic.id,
        :creator_id=>current_user.id,
        :verified=>verified)
    end
    #render :text=> current_user.id
  end

  def show
    @following=Following.find(params[:id])
  end

  def edit
    @following = Following.find(params[:id])
    

  end

  def update
    @following= Following.find(params[:id])

    if @following.update_attributes(params[:following])
      redirect_to :action => 'show', :id => @following
    else
      render :action => 'edit'
    end

  end

  def destroy
    @following = Following.find(params[:id])
    @following.destroy
    redirect_to :class=>'topics',:action => 'index'

  end
  def edit_followings
    #获取登录用户的maintaings集合
    #获取topics集合
    topic_ids = Topic.all_followable_topic_ids
    following_topic_ids=Following.followings_of_logon_user(current_user).collect{|following| following.topic_id}
    @remain_topics = Topic.find(topic_ids - following_topic_ids)
  end

  def update_followings
    #获取用户选择的topic id，并将应用的id转为整数
    selected_topic_ids = params[:selected_topic]||[]
    selected_topic_ids.collect!{|id| id.to_i}
    #新建maintainings关系
    selected_topic_ids.each do |topic_id|
      Following.create_following(topic_id,
        current_user.id,
        current_user.id,
        current_user.id)
    end
  end

  #将topic加入用户的关注
  def participate_following
    topic = Topic.find params[:id]
    if topic.create_following(current_user.id,current_user.id)
      flash[:notice]='已成功将'+topic.title+'加入关注'
      #session[:return_to] = '/my/my_c_topics'
      redirect_to :controller=>'/my',:action=>:list_topics,:id=>TOPIC_LIST_FOLLOWING
    else
      flash[:notice]='你以前已将'+topic.title+'加入关注，无须再加关注,如果你看不到你的关注信息，有可能是没有通过审核'
      # session[:return_to] = '/my/my_c_topics'
      redirect_to :controller=>'/my',:action=>:list_topics,:id=>TOPIC_LIST_FOLLOWING
    end
  end

  #取消关注某个topic
  def cancel_following
    begin
      topic = Topic.find(params[:id])
    rescue
      flash[:notice] = '地盘信息有错'
      redirect_to :controller=>:my
    else
      if topic.follower?(current_user)
        following = Following.find_by_follower_id_and_topic_id(current_user.id,topic.id)
        unless following.nil?
          following.destroy
          flash[:notice]="已经取消关注"+ "#{topic.title}"
          redirect_to :controller=>:my,:action=>:list_topics,:id=>TOPIC_LIST_FOLLOWING
        else
          flash[:notice]="信息有误"
          redirect_to :controller=>:my
        end
      else
        flash[:notice]="你无权操作"
        redirect_to :controller=>:my
      end
    end
  end

  #verify_following,这是在创建者查看地盘的时候，查看用户细节，并确定是否允许用户成为这个地盘的维护者。
  def verify_following
    if_verified = params[:verify].to_i
    begin
      following = Following.find(params[:id])
    rescue
      flash[:notice]="信息有误"
      redirect_to :controller=>:my
    else
      if if_verified == 1 
        following.update_attributes(:verified=>true,:affirmant_id=>current_user.id)
        flash[:notice]="同意该用户成为成员"
        redirect_to :controller=>:my,:action=>:list_topics,:id=>TOPIC_LIST_FOLLOWING
      else
        flash[:notice]="拒绝该用户成为成员"
        redirect_to :controller=>:my
      end
    end
  end

end
