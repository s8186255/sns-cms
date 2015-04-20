class Admin::InfoTypesController < ApplicationController
  
  before_filter :login_required
  before_filter :return_if_not_admin
  layout "admin"
  def index
    @info_types=InfoType.find :all
  end

  def new
    @content_types=ContentType.find :all
    @item_type=ItemType.new
  end

  def create
    #创建信息类型需要创建两个对象：info_type本身，还有一组item_type对象集
    #infotype本身只有两个属性：name和description，比较简单
    @info_type = InfoType.create(:name=>params[:name],
      :description=>params[:description],
      :cloud_tool_name=>params[:cloud_tool_name],
      :status=>params[:status]
    )

    #item_type有name、position、info_type_id、content_type_id四个需要填写的属性

    field_names=params[:field_names]||[]
    content_type_ids=params[:content_type_ids]||[]
    if_permit_extra_condition=params[:if_permit_extra_condition]||[]
    if_title=params[:if_title]||[]

    field_names.each_index do |x|
      ItemType.create(:name=>field_names[x],
        :position=>x,
        :content_type_id=>content_type_ids[x],
        :if_permit_extra_condition=>if_permit_extra_condition[x].to_i,
        :info_type_id=>@info_type.id,
        :if_title=>if_title[x])
    end

    
  end

  def show
    @info_type=InfoType.find(params[:id])
    @item_types = ItemType.find :all,
      :conditions=>["info_type_id = ?",
      @info_type]
  end

  def edit
    @info_type=InfoType.find(params[:id])
    @item_types = @info_type.item_types
    @content_types = ContentType.find :all
  end

  def add_field
    @content_types=ContentType.find :all
    render :partial => 'add_field'
  end

  def update_infotype
    @info_type = InfoType.find params[:id]
    @item_types = @info_type.item_types

    #item_type有name、position、info_type_id、content_type_id四个需要填写的属性
    field_names=params[:item_type_names]||[]
    content_type_ids=params[:content_type_ids]||[]

    @info_type.update_attributes params[:info_type]
    n = 0
    @item_types.each do |item_type|
      #n = item_type.position
      if item_type.id == params[:item_type_id_if_title].to_i
        item_type.update_attributes(:name=>field_names[n],
          :content_type_id=>content_type_ids[n],
          :if_title=>true)
        n+=1
      else
        item_type.update_attributes(:name=>field_names[n],
          :content_type_id=>content_type_ids[n])
        n+=1

      end
    end
    redirect_to "/admin/info_types"
  end

  def destroy
    #如下代码为临时代码，目的是清理垃圾数据
    @info_type = InfoType.find(params[:id])
    @info_type.item_types.each{|x| x.destroy} unless ItemType.find_all_by_info_type_id @info_type.id
    @info_type.topic_info_types.each{|x| x.destroy} unless ItemType.find_all_by_info_type_id @info_type.id
    @info_type.destroy
    #临时代码到此为止


    redirect_to :action => 'index'
  end




end
