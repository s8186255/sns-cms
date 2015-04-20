class InfoType < ActiveRecord::Base
  has_many :infos,:foreign_key=>'info_type_id'
  has_many :item_types,:foreign_key=>"info_type_id",:dependent=> :destroy
  has_many :topic_info_types,:foreign_key=>"info_type_id",:dependent=> :destroy
  has_many :user_info_types,:foreign_key=>"info_type_id",:dependent=> :destroy

  def self.display_tools_for_no_logon
    InfoType.find :all,:limit=>2
  end

  #找到某个信息类型的，某人创建的信息，可以采用分页和不分页方式。
  #if_page是分页和不分页的选项，0或者1；
  #page表示当前页，在控制器调用的时候，赋值采用params[:page]
  #items_per_page表示每页的条目数量
  def infos_of_info_type(user_id,if_page,page,items_per_page)
    if if_page == 1
      Info.paginate_by_sql ['select * from infos where creator_id = ? AND info_type_id = ?',user_id,self.id],
        :page => page,
        :per_page => items_per_page
    elsif if_page == 0
      Info.find_by_sql ['select * from infos where creator_id = ? AND info_type_id = ?',user_id,self.id]
    end
  end


  def title_item
    ItemType.find_by_info_type_id_and_if_title self.id,true   
  end

  def item_types
    ItemType.find_all_by_info_type_id(self.id)
  end
  
  #获取info_type相关的内容类型,这是某个info_type应该有的content_type
  def related_content_types(type)
    content_type_ids = self.item_types.collect{|x| x.content_type_id}.uniq
    if type=='id'
      content_type_ids
    elsif type =='object'
      ContentType.find self.item_types.collect{|x| x.content_type_id}.uniq
    end
  end
  
  #某用户使用定制的信息工具，可以添加的地盘的集合
  def topics_avaliable_for(user_id)
    if UserInfoType.find_by_user_id_and_info_type_id(user_id,self.id).nil?
      []
    else
      Topic.find_by_sql ['select * from topics where (id in (select topic_id from topic_info_types where info_type_id = ?) AND id in(select topic_id from maintainings where maintainer_id=?))',self.id,user_id]
    end
  end
  #获取某个info_type的display_name
  #获取topic下的某个info_type的display_name
  def name_and_order_in_topic(topic_id)
    topic_info_type=TopicInfoType.find_by_info_type_id_and_topic_id(self.id,topic_id)
    return [topic_info_type.display_name_in_topic,topic_info_type.display_order_in_topic]
  end

  #判断某个用户是否可以创建这个类型的信息
  def created_by?(user)
    ExtUser.find(user.id).user_info_types.collect{|x|x.info_type_id}.member? self.id
  end
end
