class Item < ActiveRecord::Base
  include MyConstants
  belongs_to :item_type
  belongs_to :info
  has_many :attachments,:foreign_key=>'item_id',:dependent=> :destroy

  after_update :update_info
  #获取item所属的item_type的名称
  def item_type
    return ItemType.find(self.item_type_id)
  end

  def self.create_item(item_type,item_value,info_id,lat,lng)
    if ITEM_IS_ATTACHMENT.member?(item_type.content_type_id) and !item_value.blank?
      #创建attachment对象实例,sleep 1,让后台有时间计算附件的相关信息。
      attachment = Attachment.create(:uploaded_data=>item_value)
      sleep 1

      #创建item对象实例，同时将Attachment实例的id
      item =Item.create(:item_type_id=>item_type.id,
        :info_id=>info_id,
        #以下语句，使用刚建立的attachment的id，作为item 的value保存，虽然对于图片可能需要创建几条记录，但是现在引用的时候恰是主文件的id
        :value=>attachment.id,
        :content_type_id=>item_type.content_type_id #,
        #:extra_condition_id=>extra_condition_id[i]
      )
      #同时更新attachment的item_id值
      attachment.update_attributes(:item_id=>item.id)

      #如果item是富文本
    elsif ITEM_IS_RICH_TEXT.member? item_type.content_type_id and !item_value.blank?
      #2.创建item对象实例
      item = Item.create(:item_type_id=>item_type.id,
        :info_id=>info_id,
        :value=>item_value,
        :content_type_id=>item_type.content_type_id
        # :extra_condition_id=>extra_condition_id[i]
      )

      #更新由upload_attach_file和upload_image_file最新创建attachment实例记录的item_id值
      image_files = item_value.scan(/<IMG.*?>/)
      attach_files = item_value.scan(/<A href.*?<\/A>/)

      unless image_files.blank?
        image_files.each do |image_file|
          #将所有的image_files中的元素，进行如下处理：
          #将/0000/0062 这样的第一层和第二层数据取出来，形成数组，再将数组转成字符串，再进一步转为整数，这个整数就是id
          unless image_file.scan(/\/\d+(?=\/)/).blank?
            image_id=image_file.scan(/\/\d+(?=\/)/).collect{|x| x[/\d+/]}.to_s.to_i
            Attachment.find(image_id,image_id+1,image_id+2).each{|x| x.update_attributes :item_id =>item.id}
          end
        end
      end
      #将所有的image_files中的元素，进行如下处理：
      #将/0000/0062 这样的第一层和第二层数据取出来，形成数组，再将数组转成字符串，再进一步转为整数，这个整数就是id
      unless attach_files.blank?
        attach_files.each do |attach_file|
          attachment_id=attach_file.scan(/\/\d+(?=\/)/).collect{|x| x[/\d+/]}.to_s.to_i
          Attachment.find(attachment_id).update_attributes :item_id =>item.id
        end
      end
      #如果item是普通的text类型
    elsif ITEM_IS_COMMON.member? item_type.content_type_id and !item_value.blank?
      item = Item.create(:item_type_id=>item_type.id,
        :info_id=>info_id,
        :value=>item_value,
        :content_type_id=>item_type.content_type_id
      )
      #如果item是地理信息
    elsif ITEM_IS_GEO.member? item_type.content_type_id
      lat_lng = lat+'$'+lng
      item = Item.create(:item_type_id=>item_type.id,
        :info_id=>info_id,
        :value=>lat_lng,
        :content_type_id=>item_type.content_type_id
      )
    end
    
    #更新item的if_title属性
    if item_type.if_title
      item.update_attributes :if_title=>true
    end
  end

  #修订item
  def update_item(item_type,item_value,info_id,lat,lng)
    if ITEM_IS_ATTACHMENT.member?(item_type.content_type_id) and !item_value.blank?
      #修改附件，首先删除，然后新建,sleep 1,让后台有时间计算附件的相关信息。
      #      self.attachments.destroy
      #      attachment = Attachment.create(:uploaded_data=>item_value)
      #      sleep 1
      attachment = self.attachments.find(:first)
      if attachment.nil?
        attachment = Attachment.create(:uploaded_data=>item_value)
        sleep 1

        #创建item对象实例，同时将Attachment实例的id
        item =Item.create(:item_type_id=>item_type.id,
          #以下语句，使用刚建立的attachment的id，作为item 的value保存，虽然对于图片可能需要创建几条记录，但是现在引用的时候恰是主文件的id
          :info_id=>info_id,
          :value=>attachment.id,
          :content_type_id=>item_type.content_type_id #,
          #:extra_condition_id=>extra_condition_id[i]
        )
        #同时更新attachment的item_id值
        attachment.update_attributes(:item_id=>item.id)
      else
        attachment.update_attributes(:uploaded_data=>item_value)
      end
      #修改item中的属性，主要是将新建的attachment实例的id，写入到item中
      #      self.update_attributes(:item_type_id=>item_type.id,
      #        :value=>attachment.id
      #      )
      #      #同时更新attachment的item_id值
      #           attachment.update_attributes(:item_id=>self.id)

      #如果item是富文本
    elsif ITEM_IS_RICH_TEXT.member? item_type.content_type_id and !item_value.blank?
      #2.创建item对象实例
      self.update_attributes(
        :value=>item_value
        #:content_type_id=>item_type.content_type_id
        # :extra_condition_id=>extra_condition_id[i]
      )

      #更新由upload_attach_file和upload_image_file最新创建attachment实例记录的item_id值
      image_files = item_value.scan(/<IMG.*?>/)
      attach_files = item_value.scan(/<A href.*?<\/A>/)

      image_files.each do |image_file|
        #将所有的image_files中的元素，进行如下处理：
        #将/0000/0062 这样的第一层和第二层数据取出来，形成数组，再将数组转成字符串，再进一步转为整数，这个整数就是id
        unless image_file.scan(/\/\d+(?=\/)/).blank?
          image_id=image_file.scan(/\/\d+(?=\/)/).collect{|x| x[/\d+/]}.to_s.to_i
          Attachment.find(image_id,image_id+1,image_id+2).each{|x| x.update_attributes :item_id =>item.id}
        end
      end unless image_files.blank?
      #将所有的image_files中的元素，进行如下处理：
      #将/0000/0062 这样的第一层和第二层数据取出来，形成数组，再将数组转成字符串，再进一步转为整数，这个整数就是id
      attach_files.each do |attach_file|
        attachment_id=attach_file.scan(/\/\d+(?=\/)/).collect{|x| x[/\d+/]}.to_s.to_i
        Attachment.find(attachment_id).update_attributes :item_id =>self.id
      end unless attach_files.blank?
      #如果item是普通的text类型
    elsif ITEM_IS_COMMON.member? item_type.content_type_id and !item_value.blank?
      self.update_attributes(
        :value=>item_value
      )
      #如果item是地理信息
    elsif ITEM_IS_GEO.member? item_type.content_type_id
      lat_lng = lat+'$'+lng
      self.update_attributes(
        :value=>lat_lng
      )
    end

    #更新item的if_title属性
    #    if item_type.if_title
    #      item.update_attributes :if_title=>true
    #    end
  end

  #当item的content_type_id是地理信息的时候，可以返回经纬度，第一个元素纬度，第二个元素是经度
  def lat_lng
    if self.item_type.content_type_id == 11
      return self.value.scan(/(.*)\$(.*)/).flatten.collect!{|x| x.to_f}
    end
  end

  #获得item的content type

  private
  def update_info
    Info.find(self.info_id).update_attributes :updated_at=>Time.now
  end
end
