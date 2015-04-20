class MainController < ApplicationController
  layout "main"

  #caches_page :index
  
  def index
    @topics = Topic.hottest(-1)
    render :template=>'/main/topic_list'
  end
  def newest

  end
  def recommend

  end
  def hottest
    
  end

  def search
    search_text = params[:search_text]
    unless search_text.blank?
      if params[:commit] == '搜地盘'
        @topics = Topic.search search_text
        render :template =>'/main/search_topic_list'
      elsif params[:commit] == '搜信息'
        @infos = Info.search search_text
        render :template =>'/main/search_info_list'
      end
    else
      render :template=>'/error/no_search_txt'
    end
  end

  def display_info_details
    #    @info_id = params[:id]
    #    info_type_id = Info.find(@info_id).info_type_id
    #    @item_types = ItemType.find(:all,
    #      :conditions=>["info_type_id = ?",info_type_id])
    #    @item_type_ids =@item_types.collect{|x| x.id}
    #    @items = Item.find :all,
    #      :conditions=>["item_type_id IN(?) and info_id = ?",@item_type_ids,@info_id]
    #从my_constants中获取参数，为了传递到view。
    @item_is_video = ITEM_IS_VIDEO_FOR_SHOW
    @item_is_audio = ITEM_IS_AUDIO_FOR_SHOW
    @item_is_pure_text = ITEM_IS_PURE_TEXT_FOR_SHOW
    @item_is_digital = ITEM_IS_DIGITAL_FOR_SHOW
    @item_is_img = ITEM_IS_IMG_FOR_SHOW
    @item_is_rich_text = ITEM_IS_RICH_TEXT_FOR_SHOW
    @item_is_attachment = ITEM_IS_ATTACHMENT_FOR_SHOW
    @item_is_code = ITEM_IS_CODE_FOR_SHOW
    @item_is_geo = ITEM_IS_GEO_FOR_SHOW
    @item_is_flash = ITEM_IS_FLASH_FOR_SHOW

    unless params[:topic_id].blank?
      @topic = Topic.find params[:topic_id]
      @topic_info_types = @topic.topic_info_types

    end
    @css="index_zone.css"

    @info = Info.find params[:id]
    @items = @info.items_by_position_order

    if @info.content_type_ids.member? 11
      lat_lng= @info.item_of_content_type(11).lat_lng
      @map = GMap.new("map_div")
      @map.control_init(:large_map => true,:map_type => true)
      @map.center_zoom_init(@info.item_of_content_type(11).lat_lng,4)
      @map.overlay_init(GMarker.new(lat_lng,:title =>"India", :info_window =>"India"))
    end

    #用户浏览之后，增加该信息的浏览次数
    InfoCounter.add_view_count(@info.id)

    #info所属的topic
    @topics=@info.topics

    #显示评论，同时创建评论
    @comments = @info.comments

    #创建新的评论
    @comment = Comment.new
    
    #使用common下的info_details这个共用的显示模板。
    render :template=>'/common/info_details'
  end

  def live
    @pigeon = "yes"
    render :template=>'/common/live',:layout=>false
  end
end
