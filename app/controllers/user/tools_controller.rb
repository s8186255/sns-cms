class User::ToolsController < ApplicationController
  before_filter :login_required

  #列举创建者自己创建的某一类的信息
  def my_tool
    #######################################################################
    #1.获取info_type;
    #2.获取info集合，及其中的item集合；
    #   判断info_type->item_type->content_type_id中间是否有地理信息，如果有从
    #   info_type item_type集合中判断是否有geo类型的，如果有，准备地图信息
    #######################################################################
    info_type = 39
    @infos = Info.find_by_sql ['select * from infos where info_type_id=? And creator_id=?',
      info_type,
      current_user.id
    ]

    #获取infos中的第一项item，作为显示出来的内容。
    #
    @items = Array.new
    @infos.each do |info|
      item = info.items.find(:first)
      unless item.nil?
      @items<<item
      end
    end
    #获取信息加入的topic列表
    #这个列表只能在view中实现
  end

  def my_zone
    
  end

  def my_team
    
  end

end
