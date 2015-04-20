# To change this template, choose Tools | Templates
# and open the template in the editor.

class SpecialDisplaysController<ApplicationController
   before_filter :login_required
   def grid_index
    creator_ids =Array.new
    creator_ids << current_user.id
    info_type_id = InfoType.find(:all).collect{|info_type| info_type.id}.uniq
    topic_id = Topic.find(:all).collect{|topic| topic.id}.uniq

    @infos =Info.get_infos(1,creator_ids,info_type_id,topic_id)

    #下面是借助find_first_item_id方法，实现从info找到item。

    item_ids=Array.new
    #这里将“找到每一项info对应的item_id”抽象为一个方法find_first_item_id，
    #放在模型类中，放在这里调用
    @infos.each do |info|
      item_ids << Info.find_appointed_order_item_id(info,2)
    end

    #利用@item_ids创建能够帮助显示title的item集合，便于在view层使用。
    @appointed_items=Item.find item_ids
  end
end
