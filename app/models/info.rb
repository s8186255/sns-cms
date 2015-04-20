class Info < ActiveRecord::Base
  #acts_as_fleximage :image_directory => 'public/images2'
  belongs_to :info_type
  belongs_to :user

  has_many :comments,:foreign_key=>"info_id",:dependent=> :destroy
  has_many :items,:foreign_key=>"info_id",:dependent=> :destroy
  has_many :topic_infos,:foreign_key=>"info_id",:dependent=> :destroy
  has_many :topics, :through=>:topic_infos

  has_one :info_counter,:foreign_key=>"info_id",:dependent=> :destroy

  after_create :create_info_counter


  #直接获取info所属的info_type
  def info_type
    InfoType.find self.info_type_id
  end


  def self.ads
    Info.find_by_sql ['select * from infos where id IN(select info_id from topic_infos where topic_id = ?)',242]
  end
  #本方法使用文件操作技术，将用户传递到服务器端的文件保存在服务器端。
  def self.save_file(upload,name)
    begin
      FileUtils.mkdir(upload_path) unless File.directory?(upload_path)
      bytes = upload.read
      File.open(upload_path(name), "wb") { |f| f.write(bytes) }
      File.chmod(0644, upload_path(name) )
    rescue
      raise
    end
  end

  #以file_field_tag方式发送文件的时候，它是以流的方式发送，在服务器端需要获取原始文件名
  def self.get_original_filename(upload)
    return upload.original_filename
  end

  def self.upload_path(file=nil)
    "#{RAILS_ROOT}/public/files/#{file.nil? ? '' : file}"
  end

  #如果某项item是附件类型，如图像、文件等，将会保存在两个位置：
  #一是在item库表中，以value的方式保存.例如2009829|Sunset|qouoirnu|jpg|files
  #二是在文件系统中，以文件的方式保存。
  #本方法用于从库表中找到具体的随机文件名，并结合保存位置，以便于找到实际文件。
  def self.find_files_from_item(item,file_path)
    file_name_in_file_system = item.value
    file_name_in_file_system =~/(.*)\|(.*)\|(.*)\|(.*)\|(.*)/
    if $3 !=nil
      return file_path+$3
    else
      return file_path + "winter.jpg"
    end
  end

  def self.delete_files_from_item(item,file_path)
    #创建一个文件名对象
    f = String.new

    #从item对象取出value值，其值的样式为"2009831|31|wenapkqy|jpg|files"
    file_name_in_file_system = item.value

    #使用正则表达式对上述字符串进行分组
    file_name_in_file_system =~/(.*)\|(.*)\|(.*)\|(.*)\|(.*)/

    #对取出第三项，也就是随机文件名，在判断存在之后，删除它。
    if $3 !=nil
      if File.exist?(f=file_path+'/'+$3)==true
        File.delete f
      end
    end
  end

  #根据info对象（单数），找到其对应的item第一项。
  def self.find_appointed_order_item_id(info,position)
    @item_type = ItemType.find(:first,:conditions=>["info_type_id=? AND position=?",info.info_type_id,position])
    if @item_type !=nil
      @item= Item.find(:first,:conditions=>["item_type_id=? AND info_id=?",@item_type.id,info.id])
      if @item!=nil
        return @item.id
      end
    end
  end

  ########################################################
  ###### get_infos是一个获取信息的类方法         ##########
  ########################################################
  #获取信息是系统最重要的功能
  #需求：
  #1.获取自己编写的信息，已经发布的信息，与topic进行关联。
  #2.获取某个类型的、已经发布的信息。
  #3.获取某个topic下的所有信息。
  #4.获取最新的信息
  
  #根据以上需求，明确输入参数
  #infos的creator_id,与自己发布信息有关；
  #infos的topic_id,与自己发布信息有关，
  #     只有信息与某个topic挂接在一起，才算是发布。
  #     如果不挂接，相当于信息草稿
  #infos的info_type_id,与信息类型有关；
  #topic_infos的verified，与信息是否成功发布有关；
  #
  #
  #根据是否验证、创建者、info_type的类型，列出info
  #if_verified：在topic_infos中找到验证过的infos
  #creator_id:表明是谁创建的,array类型
  #info_type_id:表明是哪一类信息，array类型
  #topic_id:表明某个topic下的信息，array类型。

  def self.get_infos(method,verified,creator_id,info_type_id,topic_id)
    case
      #1.对应method 1查看自己编写的信息，包括发布和没有发布的。infos中只关心creator_id，同时关注topic_info中是否有这个记录
      #参数输入情况：topic_infos 的 verified = 1,creator_id 是当前用户，后面两个参数为nil
      #调用案例：get_infos(1,12,nil,nil)，get_infos(0,12,nil,nil)
    when method ==1 then

      @infos = Array.new
      Info.find(:all,:conditions=>["creator_id = ?",creator_id]).each do |info|
        @infos << info if TopicInfo.find(:all,:conditions=>["verified = ?",verified]).
          collect{|topic_info| topic_info.info_id}.uniq.include?(info.id) == true
      end
      return @infos

      #2.查看某个类型的，不管是谁发布的信息，这里的关键字是：无论是谁，发布
      #可用参数：verified是确定为 1, info_type_id。
      #案例：get_infos(2,1,nil,28,nil)
    when method ==2 then

      @infos = Array.new
      Info.find(:all,:conditions=>["info_type_id = ?",info_type_id]).each do |info|
        @infos << info if TopicInfo.find(:all,:conditions=>["verified = ?",verified]).
          collect{|topic_info| topic_info.info_id}.uniq.include?(info.id) == true
      end
      return @infos

      #3.获取某个topic下的所有信息。只要是能够让用户能够看到的topic，其信息是与creator无关的。
      #可用参数：topic_id,verified
      #案例：get_infos(3,1,nil,nil,28)
    when  method ==3  then

      return @infos=Info.find(
        TopicInfo.find(:all,:conditions=>["topic_id = ? AND verified = ?",topic_id,verified]).
          collect{|topic_info| topic_info.info_id})

      #4.获取最新发布的信息,只需要verified参数
      #案例：get_infos(4,3,nil,nil,nil)
    when  method ==4  then
      #      return @infos=Info.find(
      #        TopicInfo.find(:all,:conditions=>["verified = ?",1]).
      #          collect{|topic_info| topic_info.info_id}.uniq,:order=>'created_at DESC')
      return @infos=Info.find_by_sql(["select * from infos where id IN (select info_id from topic_infos where verified = 1 )",verified])
    end
  end

  #从26个字母中生成随机变量名
  def self.random_filename
    random_filename = String.new
    alphabet=['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
    #形成8个字母组成的文件名，所以使用“7”，另外<<是追加的意思，也可以使用字符串相加的方式：+=
    0.upto(7){|x| random_filename<<alphabet[rand(alphabet.size)]}
    return random_filename
  end

  #本方法用在已知item对象（单数），获取其content_type_id,这个功能
  def self.get_content_type_id(item)
    return ItemType.find(item.item_type_id).content_type_id
  end

  #找到登录用户的前五个创建的infos
  def self.find_5_infos_created_by_logon_user(user_id)
    Info.find_by_sql ['select * from infos where creator_id=? ORDER BY updated_at DESC LIMIT 5',user_id]
  end

  #找到登录用户创建的infos
  def self.find_infos_created_by_logon_user(page,user_id)
    Info.paginate_by_sql ['select * from infos where creator_id=? ORDER BY updated_at DESC ',user_id],
      :page=>page,
      :per_page => 5
  end

  #找到info属于哪些topics
  def topics
    Topic.find_by_sql(['select * from topics where id in (select topic_id from topic_infos where info_id = ?)',self.id])
  end

  #info的所有条目类型集合，数组类型的返回值
  def item_types    
    InfoType.find(self.info_type_id).item_types
  end

  #info 中没有使用的item_types
  def blank_item_types
    ItemType.find(InfoType.find(self.info_type_id).item_types.collect{|item_type| item_type.id}-self.items.collect{|item| item.item_type_id})
  end
  #info的所有数据类型，这是现状。
  def content_type_ids
    self.items.collect{|item| item.content_type_id}.uniq
  end

 
  #查找信息的组成中的title信息；
  def title
    self.items.find_by_if_title(true)
  end
  #info的评价分数，参数n就是分数。
  def score_counter(n)
    self.comments.find_all_by_score(n).size
  end

  #info的所有items，按照显示顺序，形成数据集合。
  def items_by_position_order
    item_array=Array.new
    items_by_order=Array.new
    self.items.each do |item|
      item_array<<[item.item_type.position,item]
    end
    item_array.sort.each{|x| items_by_order<<x[1]}
    return items_by_order
  end

  #获取info的某个content_type的item。
  def item_of_content_type(id)
    self.items.find_by_content_type_id id
  end
  #搜索符合条件的info
  def self.search(string)
    string = '%'+string+'%'
    info_ids_from_item = Item.find_by_sql(["select * from items where value like ?",string]).collect{|x| x.info_id}.uniq
    #查找只是挂接在public topic的信息；
    info_ids_from_topic_info = TopicInfo.find_by_sql(["select * from topic_infos where topic_id IN(select id from topics where following_mode = ?)",1]).collect{|x| x.info_id}.uniq
    #返回上述两者的交集
    Info.find(info_ids_from_item & info_ids_from_topic_info)
  end

  #评论数量
  def number_of_comments
    unless self.info_counter.nil?
      return self.info_counter.comment_count
    else
      InfoCounter.create(:info_id=>self.id)
      return 0
    end
  end

  #点击数量
  def number_of_view
    unless self.info_counter.nil?
      return self.info_counter.view_count
    else
      InfoCounter.create(:info_id=>self.id)
      return 0
    end
  end

  #定义info所属的,用户追随的topic
  def belong_to_following_topic(user_id)
    Topic.find_by_sql [
      'select * from topics where id IN(
      select topic_id from followings where follower_id = ?) AND id IN(
      select topic_id from topic_infos where info_id = ?)',
      user_id,self.id
    ]
  end

  #显示信息的摘要信息，其组成是info的其他item的文本信息以及非文本的content_type对应的display_name。
  def summary
    #定义需要作为摘要的content_type数组，也就是5，8
    content_types = [5]
    summary_str =String.new
    other_info_str =String.new
    self.items.each do |item|
      if content_types.member?(item.content_type_id) and item.if_title == false
        summary_str = summary_str + item.value[0,24]+'...'
      else
        other_info_str = other_info_str + ContentType.find(item.content_type_id).display_name + '|'
      end
    end

    if !summary_str.blank? and !other_info_str.blank?
      return summary_str + '还包含有' + other_info_str
    elsif !summary_str.blank?
      return summary_str
    elsif !other_info_str.blank?
      return '包含有' + other_info_str
    end
  end
  #info

  #判断info实例是否属于某个topic
  def belongs_to?(topic)
    #调用topic类的实例方法，infos，第一个参数是verified，第二个参数是全部信息。
    topic.infos(1,-1).member?(self)
  end
  #判断info是否可以被修改
  def edit_by?(user)
    #只有用户是creator的时候，才可以修改,符合‘谁创建谁修改’的原则。
    self.creator_id == user.id
  end

  #判断info是否可以被查看
  def viewed_by?(user)
    #信息必须隶属user following、maintaining、create的topic
    #判断逻辑：调用Info类中的topics实例方法，获取info所属的topics，然后判断
    i = 0
    self.topics.each do |topic|
      i = +1 if topic.following_mode == 1 or topic.creator?(user) or topic.maintainer?(user)
    end
    if i == 0
     return false
    else
     return true
    end
  end

  #定义一个关联处理的方法
  private
  ######################################################
  #info创建完毕之后，都会在info_counter创建一个info_counter实例
  ######################################################
  def create_info_counter
    InfoCounter.create(:info_id=>self.id)
  end

end

