class TopicInfo < ActiveRecord::Base
  belongs_to :topic
  belongs_to :info

  def self.create_topic_info(topic_id,info_id,creator_id)
    topic =Topic.find(topic_id)
    #如果Topic中有infotype,也就是地盘中确实有这个infotype，才创建topic和info之间的关系。
    unless TopicInfoType.find_by_topic_id_and_info_type_id(topic_id,Info.find(info_id).info_type_id).nil?
      if TopicInfo.find(:all,:conditions=>['info_id=? AND topic_id =?',info_id,topic_id]).blank?
        if topic.if_verify_info == false or Info.find(info_id).creator_id == creator_id
          topic.topic_infos.create(:info_id=>info_id,
            :verified=>true,
            :creator_id =>creator_id,
            :affirmant_id =>creator_id
          )
        elsif topic.if_verify_info == true
          topic.topic_infos.create(:info_id=>info_id,
            :verified=>false,
            :creator_id =>creator_id
          )
        end

        #增加topic_counter的处理内容
        TopicCounter.add_info_count(topic_id)
      end
    else
      return -1
    end
  end

  def self.find_topic_infos_to_be_verified_by_topic_maintainer(user_id)
    topic_infos=TopicInfo.find_by_sql ['select * from topic_infos where topic_id in(select topic_id from maintainings where maintainer_id = ?) AND verified = 0',user_id]
    topic_info_ids=topic_infos.collect{|x| x.topic_id}.uniq

    hash_topic_infos=Hash.new

    topic_info_ids.each do |id|
      hash_topic_infos["#{id}"]=[]
      topic_infos.each do |topic_info|
        if topic_info.topic_id ==id
          hash_topic_infos["#{id}"]<<topic_info.info_id
        end
      end
    end
    #返回值为一个hash,其中包含了下标，值。
    return hash_topic_infos
  end

  #更新topic与info之间的关系，user_select_topic_ids是数据集
  def self.update_topic_info(info_id,user_select_topic_ids)
    #获取info现在挂接的topic
    topic_ids = TopicInfo.find_all_by_info_id(info_id).collect{|topic_info| topic_info.topic_id}.uniq
    #获取需要删除的topic和需要新建关系的topic。
    topic_ids_for_create = user_select_topic_ids - topic_ids
    topic_ids_for_delete = topic_ids - user_select_topic_ids
    #新建topic_info关系
    topic_ids_for_create.each{|topic_id| TopicInfoType.create(:topic_id=>topic_id,:info_id=>info_id)} unless topic_ids_for_create.blank?
    #删除topic_info关系
    topic_ids_for_delete.each{|topic_id| TopicInfoType.find_by_topic_id_and_info_id(topic_id,info_id).destroy} unless topic_ids_for_delete.blank?
  end
  #######################
  #实例方法
  #######################
  def topic
    Topic.find self.topic_id
  end

  def info
    begin
      info = Info.find self.info_id
    rescue
      return false
    else
      return info
    end
  end
end
