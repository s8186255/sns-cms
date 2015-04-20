class Maintaining < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user

  def self.find_maintainings_to_be_verified_by_topic_creator(page,user_id)
    Maintaining.paginate_by_sql ['select * from maintainings where topic_id in(select id from topics where creator_id =?) AND verified = 0',user_id],
      :page=>page,
      :per_page=>5
  end

  def self.maintainings_of_logon_user(user)
    user.maintainings
  end
  #######################
  #实例方法
  #######################
  def topic
    Topic.find self.topic_id
  end

  def maintainer
    ExtUser.find self.maintainer_id
  end

end
