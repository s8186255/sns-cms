class Topic < ActiveRecord::Base
  include MyConstants
  #acts_as_taggable

  belongs_to :user
  belongs_to :topic_type
  

  has_many :users
  has_many :topic_infos,:foreign_key=>'topic_id',:dependent=>:destroy
  has_many :topic_info_types,:foreign_key=>'topic_id',:dependent=>:destroy
  has_many :team_topics
  has_many :followings,:foreign_key=>'topic_id',:dependent=>:destroy
  has_many :maintainings,:foreign_key=>'topic_id',:dependent=>:destroy

  has_one :topic_avatar,:foreign_key=>'topic_id',:dependent=>:destroy
  has_one :topic_counter,:foreign_key=>'topic_id',:dependent=>:destroy
  has_one :display_topic,:foreign_key=>'topic_id',:dependent=>:destroy

  validates_presence_of :title,:my_title,:topic_type_id
  validates_uniqueness_of :title

  #获取topics是经常使用的一个方法
  #需求：
  #1.得到可follow的主题
  #2.得到自己已经following的主题
  #3.得到自己创建的主题
  #4.得到可以加入信息的主题，分为需要审核和不需要审核的两类主题。
  #在将信息加入到某个topic的过程中，内含这样一个逻辑：只有用户following这个主题，
  #才可以将这个信息加入。
  #输入参数：
  #1.creator_id
  #2.if_followable，与3、4联合使用
  #3.status
  #4.if_verify_follower
  #5.if_permit_other_infos，通常与6联合使用
  #6.if_verify_info
  #基于上述几个参数的选择，可以完成上述四个需求
  #
  #
  ##################
  #以下是类方法     #
  ##################
  #获取登录者创建的topic
  def self.find_all_topics_created_by_logon_user(user)
    Topic.find(:all,
      :conditions=>['status = 1 and creator_id = ?',user.id],
      :order=>'created_at DESC'
    )
  end

  #获取登录者创建的topic五个
  def self.find_5_topics_created_by_logon_user(user)
    Topic.find(:all,
      :conditions=>['status = 1 and creator_id = ?',user.id],
      :order=>'created_at DESC',
      :limit=>5)
  end
  
  def self.find_topics_created_by_logon_user(page,user)
    user.topics.paginate :page=>page,:per_page => 5,
      :conditions=>'status = 1',
      :order=>'updated_at'
  end
  #following id是登录者，同时topic的状态正常。
  def self.find_topics_followed_by_logon_user(page,user_id)
    Topic.paginate_by_sql(['select * from topics where id IN(select topic_id from followings where follower_id = ?) AND status = 1',user_id],
      :page=>page,
      :per_page => 5
    )
  end

  #maintainer id是登录者，同时topic的状态正常。
  def self.find_topics_maintained_by_logon_user(page,user_id)
    Topic.paginate_by_sql(['select * from topics where id IN(select topic_id from maintainings where maintainer_id = ?) AND status = 1',user_id],
      :page=>page,
      :per_page => 5
    )
  end
  
  def self.find_all_topics_maintained_by_logon_user(user)
    user.topics.find_by_sql(['select * from topics where id IN(select topic_id from maintainings where maintainer_id = ?) AND status = 1',user.id])
  end

  def self.all_maintainable_topic_ids
    return Topic.find_by_sql(['select * from topics where maintaining_mode<>0']).collect{|topic| topic.id}
  end

  def self.all_followable_topic_ids
    return Topic.find_by_sql(['select * from topics where following_mode<>0']).collect{|topic| topic.id}
  end
  #找到用户可以添加某类信息的topics集合，条件是topic在用户的maintain范围，同时topic在topic_info_type范围内。
  def self.topics_added_with_info(user_id,info_type_id)
    Topic.find_by_sql(['select * from topics where id IN (select topic_id from maintainings where maintainer_id = ?) and id IN(select topic_id from topic_info_types where info_type_id = ?)',user_id,info_type_id])
  end

  #找到最热门的地盘
  def self.hottest(number)
    if number == -1
      Topic.find_by_sql(["select * from topics where (status = ?) AND (following_mode = ? or following_mode = ?) AND id IN (select topic_id from topic_counters order by following_count)",1,1,2])
    else
      Topic.find_by_sql(["select * from topics where (status = ?) AND (following_mode = ? or following_mode = ?) AND id IN (select topic_id from topic_counters order by following_count) limit ?",1,1,2,number])
    end
  end

  def self.recommended

  end

  #全局查找符合关键字的topic,title/description/昵称含有搜索字的；同时是public或者member的；同时status是正常状态的；
  def self.search(string)
    string = '%'+string+'%'
    Topic.find_by_sql(["select * from topics where (status = ?) AND (following_mode = ? or following_mode = ?) AND (title like ? or description like ? or my_title like ?) ",
        1,#status为1
        1,#following mode为1，public类型
        2,#following mode 为2，member类型，private类型不在搜索范围内
        string,#topic的title中含有这个搜索关键字
        string,#topic的description中含有这个搜索关键字
        string])#topic的mytitle中含有这个搜索关键字
  end


  #########################
  #以下是实例方法
  #########################

  #获取topic下的所有维护者信息
  def maintainers(if_verified)
    return ExtUser.find_by_sql(['select * from users where id IN(select maintainer_id from maintainings where topic_id = ? and verified = ?)',self.id,if_verified])
  end

  #获取topic下的所有追随者信息
  def followers(if_verified)
    return ExtUser.find_by_sql(['select * from users where id IN(select follower_id from followings where topic_id = ? and verified = ?)',self.id,if_verified])
  end

  #获取topic的helpers帮手
  def helpers
    return ExtUser.find_by_sql(['select * from users where id IN(select maintainer_id from maintainings where topic_id = ? and verified = 1 and if_helper_of_topic_creator = 1)',self.id])
  end

  #获取topic的maintainers，but no helpers
  def common_maintainers
    return ExtUser.find_by_sql(['select * from users where id IN(select maintainer_id from maintainings where topic_id = ? and verified = 1 and if_helper_of_topic_creator != 1)',self.id])
  end

  #获取topic下的所有信息,info_number是-1表示显示所有的信息，否则只是显示有限数量的信息。
  def infos(if_verified,info_number)
    if info_number == -1
      return Info.find_by_sql(['select * from infos where id IN(select info_id from topic_infos where topic_id = ? and verified = ?) order by updated_at',self.id,if_verified])
    else
      return Info.find_by_sql(['select * from infos where id IN(select info_id from topic_infos where topic_id = ? and verified = ?) order by updated_at limit ? ',self.id,if_verified,info_number])
    end
  end

  #查找topic下的某个info_type的所有信息，同时可以指明需要什么样的信息
  def infos_of_info_type(if_verified,info_type_id)
    unless info_type_id ==-1
      Info.find_by_sql(["select * from infos where id IN(select info_id from topic_infos where topic_id = ? and verified = ?) AND info_type_id = ? order by updated_at DESC",self.id,if_verified,info_type_id])
    else
      Info.find_by_sql(["select * from infos where id IN(select info_id from topic_infos where topic_id =? AND verified = ?) order by updated_at DESC",self.id,if_verified])
    end
  end
  
  #获取topic实例的info_types
  def info_types
    InfoType.find(self.topic_info_types.collect{|topic_info_type| topic_info_type.info_type_id}.uniq)
  end



  #获取某个用户在维护地盘的时候，新建info_types的选项。
  def info_types_available_for(user_id)
    InfoType.find_by_sql ['select * from info_types where id IN(select info_type_id from user_info_types where user_id =?) AND id IN(select info_type_id from topic_info_types where topic_id=?)',user_id,self.id]
    #InfoType.find(self.topic_info_types.collect{|topic_info_type| topic_info_type.info_type_id}.uniq)
  end

  def topic_info_types
    TopicInfoType.find_by_sql(['select * from topic_info_types where topic_id = ? order by display_order_in_topic ',self.id])
  end

  def update_topic_info_types(user_select_info_type_ids)
    #获取topic现有的应用
    info_type_ids = self.topic_info_types.collect{|topic_info_type| topic_info_type.info_type_id}.uniq
    #获取需要删除的应用和需要新建的应用。
    #用户选择，但不在已有范围的，需要新建。
    info_type_ids_for_create = user_select_info_type_ids - info_type_ids
    #将既有的，但是没有选中的，需要删除
    info_type_ids_for_delete = info_type_ids - user_select_info_type_ids
    #新建用户应用关系
    topic_info_type_ids = Array.new
    info_type_ids_for_create.each do |info_type_id|
      topic_info_type = TopicInfoType.create(
        :topic_id=>self.id,
        :info_type_id=>info_type_id
      )
      #topic_info_type_ids<<topic_info_type.id
    end unless info_type_ids_for_create.blank?
    #删除用户应用关系,同时将topic_info关系也删除。
    info_type_ids_for_delete.each do |info_type_id|
      TopicInfoType.find_by_topic_id_and_info_type_id(self.id,info_type_id).destroy unless info_type_ids_for_delete.blank?
      InfoType.find(info_type_id).infos.each do |info|
        #TopicInfo.find_all_by_topic_id_and_info_id.each{|topic_info| topic_info.destroy}
        TopicInfo.destroy_all(:topic_id=>self.id,:info_id=>info.id)
      end
    end
    #return topic_info_type_ids
  end

  #地盘浏览次数
  def view_count
    unless TopicCounter.find_by_topic_id(self.id).nil?
      TopicCounter.find_by_topic_id(self.id).view_count
    else
      return 0
    end
  end
  #地盘的会员数量
  def following_count
    unless TopicCounter.find_by_topic_id(self.id).nil?
      TopicCounter.find_by_topic_id(self.id).following_count
    else
      return 0
    end  end
  #地盘的信息数量
  def info_count
    unless TopicCounter.find_by_topic_id(self.id).nil?
      TopicCounter.find_by_topic_id(self.id).info_count
    else
      return 0
    end
  end
  
  #地盘的info_type的显示名称
  def display_name_of_info_type(info_type_id)
    return TopicInfoType.find_by_topic_id_and_info_type_id(self.id,info_type_id).display_name_in_topic
  end

  #查找某个topic下的某个信息；
  def search_info(string)
    string = '%'+string+'%'
    Info.find_by_sql(['select * from infos where id IN(select info_id from topic_infos where topic_id = ?) AND  id IN(select info_id from items where value like ?) ',self.id,string])
  end

  #创建topic和user的追随关系
  def create_following(user_id,creator_id)
    if self.status == 1 and self.creator_id != user_id
      if Following.find_by_follower_id_and_topic_id(user_id,self.id)
        return false
      else
        #如果topic的following_mode是public，用户加入关注时设置verified为1,同时创建affirmant_id.
        #如果topic的following_mode是member，则需要topic的创建者或者维护者进行认证。
        case self.following_mode
        when 1
          following = Following.new(
            :follower_id=>user_id,
            :topic_id=>self.id,
            :creator_id=>creator_id,
            :verified=>1,
            :affirmant_id=>creator_id
          )
          following.save ? true:false
        when 2
          following = Following.new(
            :follower_id=>user_id,
            :topic_id=>self.id,
            :creator_id=>creator_id,
            :verified=>0
          )
          following.save ? true:false
        end
      end
    else
      return false
    end
  end

  #创建topic和user的维护关系,与following不同的是，所有的maintaining关系都需要verify。
  def create_maintaining(user_id,creator_id)
    #只有topic的状态正常、同时“user-topic”maintain关系中的user不是
    if self.status == 1 and self.creator_id != user_id
      if Maintaining.find_by_maintainer_id_and_topic_id(user_id,self.id)
        return false
      else
        maintaining = Maintaining.new(
          :maintainer_id=>user_id,
          :topic_id=>self.id,
          :creator_id=>creator_id,
          :verified=>0
        )
        maintaining.save ? true:false
      end
    else
      return false
    end
  end
  #查找topic实例下的需要审核的maintaining申请信息
  def maintainings_for_verify
    Maintaining.find_all_by_verified_and_topic_id(0,self.id)
  end
  #查找topic实例下的需要审核的following申请信息
  def followings_for_verify
    Following.find_all_by_verified_and_topic_id(0,self.id)
  end
  #查找topic实例下的需要审核的新加入的信息
  def infos_for_verify
    TopicInfo.find_all_by_verified_and_topic_id(0,self.id)
  end


  #判断topic实例与用户之间的关系,返回值，0表示“不是”；1表示“是”
  def creator?(user)
    true if self.creator_id == user.id
  end

  def maintainer?(user)
    unless Maintaining.find_by_topic_id_and_maintainer_id_and_verified(self.id,user.id,1).nil?
      return true
    else
      return false
    end
  end
  def follower?(user)
    unless Following.find_by_topic_id_and_follower_id_and_verified(self.id,user.id,1).nil?
      true
    else
      false
    end
  end

  #判断当前topic相关的user是否是topic creator的帮手。
  #从maintaining的if_helper_of_topic_creator获取用户是否是topic的帮手。
  def helper?(user)
    unless Maintaining.find_by_topic_id_and_maintainer_id_and_verified_and_if_helper_of_topic_creator(self.id,user.id,1,1).nil?
      return true
    else
      return false
    end
  end
  #更新topic的图片
  def update_avatar(image)
    #找到topic对应的avatar实例，然后使用attachment插件的方法attachment.update_attributes(:uploaded_data=>...)即可；
    avatar = Avatar.find_by_topic_id(self.id)
    unless avatar.nil?
      avatar.update_attributes(:uploaded_data=>image) unless avatar.nil?
    else
      avatar = Avatar.create(:uploaded_data=>image) if avatar.nil?
      avatar.update_attributes(:topic_id=>self.id)
    end
  end

  #判断topic_info_type是否属于某个topic实例
  def has_topic_info_type?(topic_info_type_id)
    self.topic_info_types.
      collect{|x| x.id}.
      member?(topic_info_type_id)
  end
  #判断info是否属于某个topic实例
  def has_info?(info_id)
    self.topic_infos.
      collect{|x| x.info_id}.
      member?(info_id)
  end

  #地盘中最新信息
  def newest
    Info.find_by_sql ["select * from infos where id IN(select info_id from topic_infos where topic_id =? AND verified =1) order by updated_at DESC",self.id]
  end

  #地盘标识
  def indicator
    return 'p' if self.following_mode == 0
    return 'P' if self.following_mode == 1
    return 'M' if self.following_mode == 2
  end
  #判断topic中是否含有某个信息工具，即info_type
  def has_info_type?(info_type_id)
    self.topic_info_types.collect{|x| x.info_type_id}.member? info_type_id
  end

  #配置topic的maintainer为helper
  def config_maintainer_as_helper(maintainer_id)
    Maintaining.find_by_topic_id_and_maintainer_id_and_verified(self.id,maintainer_id,1).update_attributes(:if_helper_of_topic_creator=>1)
  end
  def config_maintainer_as_common(maintainer_id)
    Maintaining.find_by_topic_id_and_maintainer_id_and_verified(self.id,maintainer_id,1).update_attributes(:if_helper_of_topic_creator=>0)
  end
  #获取topic的创建者login
  def creator_login
    ExtUser.find(self.creator_id).login
  end

  #更新topic的maintaining
  def update_helpers(maintainer_ids)
    unless maintainer_ids.nil?
      self.maintainers(1).each do |maintainer|
        if maintainer_ids.member? maintainer.id.to_s
          self.config_maintainer_as_helper(maintainer.id)

        else
          self.config_maintainer_as_common(maintainer.id)
        end
      end
    else
      self.maintainers(1).each do |maintainer|
        self.config_maintainer_as_common(maintainer.id)
      end
    end
  end
end
