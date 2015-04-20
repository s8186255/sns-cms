class TopicInfoType < ActiveRecord::Base
  belongs_to :topic
  belongs_to :info_type

  #在topic_info_type被删除之后，同时需要删除topic和info之间的关系：topic_info
  after_destroy :delete_topic_info
  #validates_presence_of :display_name_in_topic

  #以下是类方法
  def self.create_topic_info_types(topic_id,info_type_id)

  end

  #以下是实例方法
  def infos_of_topic_info_type
    Info.find_by_sql ['select * from infos where info_type_id = ? and id IN(select info_id from topic_infos where topic_id = ?) ',self.info_type_id,self.topic_id]
    #return info.items.find_by_if_title true
  end

  def topic
    Topic.find self.topic_id
  end
  def info_type
    InfoType.find self.info_type_id
  end

  private
  #此方法供 after_destroy的时候调用，删除topic_info
  def delete_topic_info
    topic_info = TopicInfo.find_by_sql(["select * from topic_infos where info_id in(select id from infos where info_type_id in (select info_type_id from topic_info_types where info_type_id = ?))",self.info_type_id])
    topic_info.each{|x| x.destroy}
  end
end
