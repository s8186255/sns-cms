class ExtUser < User


  #以下不采用多页
  #用户创建的topics
  def topics_created
    self.topics.find :all,
      :conditions=>'status = 1',
      :order=>'updated_at'
  end


  #用户follow的topics
  def topics_following
    Topic.find_by_sql ['select * from topics where id IN(
      select topic_id from followings where follower_id = ? AND verified = 1)
      order by updated_at',
      self.id]
  end

  #用户维护的topics
  def topics_maintaining
    Topic.find_by_sql ['select * from topics where id IN(
      select topic_id from maintainings where maintainer_id = ? AND verified = 1)
      order by updated_at',
      self.id]
  end

  #用户follow的topic是下的信息
  def infos_in_following_topics
    Info.find_by_sql ['select * from infos where id IN(
      select info_id from topic_infos where topic_id IN(
      select topic_id from followings where follower_id = ? AND verified = 1))
      order by updated_at DESC',
      self.id]
  end
  #获取某类信息的集合
  def infos_of_info_type(info_type_id)
    Info.find :all,
      :conditions=>['creator_id=? AND info_type_id=?',
      self.id,
      info_type_id],
      :order=>'updated_at DESC'
  end

  #获取用户定制的信息工具
  def info_types
    ids = UserInfoType.find_all_by_user_id(self.id).collect{|x| x.info_type_id}.uniq
    return InfoType.find(ids)
  end

  #以下是采用多页方式
  #  def topics_created(page)
  #    self.topics.paginate :page=>page,:per_page => 5,
  #      :conditions=>'status = 1',
  #      :order=>'updated_at'
  #  end
  #
  #
  #  def topics_following(page)
  #    Topic.paginate_by_sql ['select * from topics where id IN(select topic_id from followings where follower_id = ?) order by updated_at',self.id],
  #      :page=>page,
  #      :per_page => 5
  #  end
  #
  #  def topics_maintaining(page)
  #    Topic.paginate_by_sql ['select * from topics where id IN(select topic_id from maintainings where maintainer_id = ?) order by updated_at',self.id],
  #      :page=>page,
  #      :per_page => 5
  #  end

end
