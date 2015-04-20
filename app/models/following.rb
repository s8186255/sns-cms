class Following < ActiveRecord::Base
  belongs_to :topic,:counter_cache=>true
  belongs_to :user

  #列表可选
  #############################
  #类方法
  #############################
  def self.find_followings_to_be_verified_by_topic_maintainer(page,user_id)
    Following.paginate_by_sql ['select * from followings where topic_id in(select topic_id from maintainings where maintainer_id =?) AND verified = 0',user_id],
      :page=>page,
      :per_page=>5
  end

  def self.followings_of_logon_user(user)
    user.followings
  end
  
  def self.create_following(topic_id,follower_id,creator_id,affirmant_id)
    #follower_id
    #topic_id
    #verified
    #creator_id
    #affirmant_id
    if Following.find(:all,:conditions=>['topic_id=? AND follower_id =?',topic_id,follower_id]).blank?
      if Topic.find(topic_id).following_mode ==1
        Following.create :follower_id=>follower_id,
          :topic_id=>topic_id,
          :verified=>true,
          :creator_id=>creator_id,
          :affirmant_id=>affirmant_id
        #创建topic_counter记录
        TopicCounter.add_following_count(topic_id)
      elsif Topic.find(topic_id).following_mode ==2
        Following.create :follower_id=>follower_id,
          :topic_id=>topic_id,
          :verified=>false,
          :creator_id=>creator_id
      end
    end
  end

  #######################
  #实例方法
  #######################
  def topic
    Topic.find self.topic_id
  end
  def follower
    ExtUser.find self.follower_id
  end

end
