class MaintainingsController < ApplicationController
  before_filter :login_required
  before_filter :info_of_user
  layout "my"

  def index
    #查找申请加入topic的请求。
    begin
      @topic = Topic.find params[:id]
    rescue
      flash[:notice]='你要查找的审核信息不存在'
      redirect_to '/my'
    else
        @maintainings=@topic.maintainings_for_verify
        render :template=>'/common/relation_list'

      
    end
  end

  #  def new
  #    #######################
  #    #创建一个对象实例，供视图使用
  #    #######################
  #    @maintaining = Maintaining.new
  #  end
  #
  #  def create
  #    #######################
  #    #创建maintaining对象实例
  #    # maintainer_id
  #    # topic_id
  #    # verified
  #    # creator_id
  #    #######################
  #    topic_id = params[:topic_id]
  #    topic = Topic.find(topic_id)
  #    if Maintaining.find(:all,:conditions=>['maintainer_id=? AND topic_id =?',current_user.id,topic_id]).blank?
  #      if topic.maintaining_mode == TOPIC_MAINTAINING_MODE_PUBLIC
  #        verified = true
  #        affirmant_id = topic.creator_id
  #      elsif topic.maintaining_mode == TOPIC_MAINTAINING_MODE_MEMBER
  #        verified = false
  #      elsif topic.maintaining_mode == TOPIC_MAINTAINING_MODE_PRIVATE
  #        verified = true
  #        affirmant_id = topic.creator_id
  #      end
  #
  #      topic.maintainings.create(:maintainer_id=>current_user.id,
  #        :verified=>verified,
  #        :creator_id =>current_user.id,
  #        :affirmant_id =>affirmant_id
  #      )
  #    else
  #      render :text=>'已经建立维护关系'
  #    end
  #  end
  #
  #  def new1020
  #
  #    #    @all_topics_status_is_open = Topic.find(:all,:conditions=>["status = 1 AND topic_type_id IN ?",[2,3]])
  #    #    @all_topics_followable_is_on = @all_topics_status_is_open
  #    #    @my_following_topic_ids = Following.find(:all,
  #    #      :conditions=> ["follower_id=?",current_user]).collect{|x| x.topic_id}.uniq
  #    #    @optional_topic_ids = @all_topic_ids - @my_following_topic_ids
  #    #    @optional_topics = Topic.find @optional_topic_ids
  #
  #    #public_optional_topics
  #    @public_optional_topics = Topic.find :all,:conditions=>['topic_type_id IN(?)',PUBLIC_OPTIONAL_TOPIC_IDS]
  #
  #    #member_optional_topics
  #    @member_optional_team_topics = TeamTopic.find :all,:group=>'team_id',:conditions=>{
  #      :team_id=>TeamUser.find(:all,:conditions=>{:user_id=>current_user.id}).collect { |team_user| team_user.team_id  }.uniq,
  #      :operation_id=>FOLLOW_OPERATION_ID
  #    }
  #  end
  #
  #  def create1020
  #    #如下是准备创建following所需的参数,其中模型所需的
  #    #follower_id,creator_id的值都是current_user
  #    #verified则是根据topic的if_verify_follower.
  #    #topic_id来自选择的topic
  #
  #
  #    @picked_topics = Topic.find(params[:picked_topics]||[])
  #
  #    @picked_topics.each do |topic|
  #      if TOPIC_TYPE_IDS_NEED_VERIFY.member? topic.topic_type_id
  #        verified = VERIFIED_IS_FALSE
  #      else
  #        verified = VERIFIED_IS_TRUE
  #      end
  #      Following.create(:follower_id=>current_user.id,
  #        :topic_id=>topic.id,
  #        :creator_id=>current_user.id,
  #        :verified=>verified)
  #    end
  #    #render :text=> current_user.id
  #  end
  #
  #
  #
  #  def edit
  #    @following = Following.find(params[:id])
  #
  #
  #  end
  #
  #  def update
  #    @following= Following.find(params[:id])
  #
  #    if @following.update_attributes(params[:following])
  #      redirect_to :action => 'show', :id => @following
  #    else
  #      render :action => 'edit'
  #    end
  #
  #  end
  #
  #  def destroy
  #    @following = Following.find(params[:id])
  #    @following.destroy
  #    redirect_to :class=>'topics',:action => 'index'
  #
  #  end
  #
  #  def edit_maintainings
  #    #获取登录用户的maintainings集合
  #    #获取topics集合
  #    topic_ids = Topic.all_maintainable_topic_ids
  #    maintaining_topic_ids=Maintaining.maintainings_of_logon_user(current_user).collect{|maintaining| maintaining.topic_id}
  #    @remain_topics = Topic.find(topic_ids - maintaining_topic_ids)
  #  end
  #
  #  def update_maintainings
  #    #获取用户选择的topic id，并将应用的id转为整数
  #    selected_topic_ids = params[:selected_topic]||[]
  #    selected_topic_ids.collect!{|id| id.to_i}
  #    #新建maintainings关系
  #    selected_topic_ids.each do |topic_id|
  #      if Topic.find(topic_id).maintaining_mode == TOPIC_MAINTAINING_MODE_PUBLIC
  #        Maintaining.create(:topic_id=>topic_id,
  #          :maintainer_id=>current_user.id,
  #          :verified=>true,
  #          :creator_id=>current_user.id,
  #          :affirmant_id=>current_user.id)
  #      elsif  Topic.find(topic_id).maintaining_mode == TOPIC_MAINTAINING_MODE_MEMBER
  #        Maintaining.create(:topic_id=>topic_id,
  #          :maintainer_id=>current_user.id,
  #          :verified=>false,
  #          :creator_id=>current_user.id)
  #      end
  #    end
  #  end

  #加入维护某个topic，不需要进行topic_id的审核。
  def participate_maintaining
    begin
      topic = Topic.find(params[:id])
    rescue
      flash[:notice]='已成功完成'+topic.title+'的维护申请'
      redirect_to :controller=>:my
    else
      if topic.create_maintaining(current_user.id,current_user.id)
        flash[:notice]='已成功完成'+topic.title+'的维护申请'
        redirect_to :controller=>'/my',:action=>:list_topics,:id=>TOPIC_LIST_MAINTAINING
      else
        flash[:notice]='你以前已经申请对'+topic.title+'维护'
        redirect_to :controller=>'/my',:action=>:list_topics,:id=>TOPIC_LIST_MAINTAINING
      end
    end
  end

  #取消参与维护某个topic，需要对topic_id进行审核
  def cancel_maintaining
    begin
      topic = Topic.find(params[:id])
    rescue
      flash[:notice]='不能找到相关信息'
      redirect_to :action=>:index
    else
      if topic.maintainer?(current_user)
        maintaining = Maintaining.find_by_maintainer_id_and_topic_id(current_user.id,topic.id)
        unless maintaining.nil?
          maintaining.destroy
          flash[:notice]='已经不再维护'+ topic.title
          redirect_to '/my',:action=>:list_topics,:id=>TOPIC_LIST_MAINTAINING
        else
          flash[:notice]='删除不成功'
          redirect_to '/my',:action=>:list_topics,:id=>TOPIC_LIST_MAINTAINING
        end
      else
        flash[:notice]='不能找到相关信息'
        redirect_to :action=>:index
      end
    end
  end

  #  def verify_maintaining1
  #    if params[:verify_id].to_i ==0
  #      Maintaining.find_by_maintainer_id_and_topic_id(params[:user_id],params[:topic_id]).destroy
  #    elsif params[:verify_id].to_i ==1
  #      Maintaining.find_by_maintainer_id_and_topic_id(params[:user_id],params[:topic_id]).update_attributes(:verified=>true)
  #    end
  #  end

  #verify_maintaining,这是在创建者查看地盘的时候，查看用户细节，并确定是否允许用户成为这个地盘的维护者。
  def verify_maintaining
    if_verified = params[:verify_id].to_i
    begin
      maintaining = Maintaining.find(params[:id])
    rescue
      flash[:notice] = '验证出错'
      redirect_to :controller=>:my,:action=>:index
    else

      if if_verified == 1 
        maintaining.update_attributes(:verified=>true,:affirmant_id=>current_user.id)
        flash[:notice]="同意该用户成为维护者"
        redirect_to :controller=>'/my',:action=>:list_topics,:id=>TOPIC_LIST_MAINTAINING
      else
        flash[:notice]="拒绝该用户成为维护者"
        redirect_to :controller=>'/my',:action=>:list_topics,:id=>TOPIC_LIST_MAINTAINING
      end
    end
  end
 
end
