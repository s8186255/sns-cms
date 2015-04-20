class InfosController < ApplicationController
  #before_filter :login_required,:only=>[:get_my_infos,:list_info_types,:new,:create]
  before_filter :login_required
  before_filter :info_of_user
  
  skip_before_filter :verify_authenticity_token

  #layout "my"

  #以下是index,get_newst_infos,get_my_infos,都是进行info列举的方法。
  #index列出所有的最新信息。
  def index
    @topic = Topic.find(params[:id])
    @infos = @topic.infos(0,-1)
  end


  def get_my_infos
    #找到当前用户编写的信息，包括发布的和未发布的,调用get_infos方法一。

    @infos= Info.get_infos(1,1,current_user.id,nil,nil) + Info.get_infos(1,0,current_user.id,nil,nil)
    #初始化一系列的数组
    #item_ids是第一个item的id的集合，目的就是使用这个item_id的value作为显示。
    item_ids=Array.new

    #对info集合进行处理
    @infos.each do |info|
      item_ids << Info.find_appointed_order_item_id(info,0)
    end

    #利用@item_ids创建能够帮助显示title的item集合。
    @appointed_items=Item.find item_ids,:order=>'created_at DESC'
  end

  def new1
    # @topics=Topic.find :all
    # info_type_id是从选择云工具集中的某项获得（list_info_types），将决定处理什么样的信息。
    # 这里采用session方式将此变量值传递到其他方法中。是否可以采用protected或者private方法进行参数传递呢？
    info_type_id = params[:info_type_id]
    
    #判断用户获得的功能集为空，功能集就是session[:function_ids]
    unless session[:function_ids].nil?
      case info_type_id
      when '28'
        #function_id是规划中的id，与info_type_id不是一回事
        #当function_id 等于 -1的时候，允许大家都可以使用。这个可以采用常量的方法。
        function_id = -1

        #判断是否包含上述功能点。
        if session[:function_ids].include?(function_id) || function_id == -1
          @item_types =ItemType.find :all,
            :conditions=>["info_type_id = ?",info_type_id]
          #以下列出可以将信息加入到的主题列表
          @my_following_topic_ids = Following.find(:all,
            :conditions=> ["follower_id=?",current_user.id]).collect{|x| x.topic_id}.uniq
          @optional_topics = Topic.find(:all,
            :conditions=>["if_permit_other_infos = ?",1])
        else
          render :text=>"no right"
        end
      else
        flash[:notice]="meiyou"
        redirect_to '/infos/list_info_types'
      end
    else
      render :text=>"no right"
    end
  end

  def new
    #info_type表明信息应用工具
    @info_type = InfoType.find params[:id]
    @topic_id = params[:topic_id]
 
    #从my_constants中获取参数，为了传递到view。
    @item_is_attachment = ITEM_IS_ATTACHMENT
    @item_is_common = ITEM_IS_COMMON
    @item_is_rich_text = ITEM_IS_RICH_TEXT
    @item_is_geo = ITEM_IS_GEO

    #item_types参数为了输入具体的信息条目做好数据准备。
    @item_types = @info_type.item_types

    #准备item_types中的content_type_id是GEO的地图信息的
    if @info_type.related_content_types('id').member? 11
      #创建初始化的地图，这里可以结合user所在的地点，进行操作，如果是空，则缺省到国家。
      @map = GMap.new("map_div")
      @map.control_init(:large_map => true,:map_type => true)
      @map.center_zoom_init([22.792388,79.497070],4)
      @map.overlay_init(GMarker.new([22.792388,79.497070],:title =>"India", :info_window =>"India"))
      @map.record_init @map.on_click("function(overlay,point){updateLocation(point)}")
    end

    #列出的topic符合如下条件：
   
    @maintainable_topics = current_user.topics_maintaining
    
  end

  def show_info_details
    #准备view中使用的变量
    @item_is_attachment = ITEM_IS_ATTACHMENT
    @item_is_common = ITEM_IS_COMMON
    @item_is_rich_text = ITEM_IS_RICH_TEXT
    @item_is_geo = ITEM_IS_GEO
    #以下是生成item_types,准备信息的录入细节。
    info_type_id =params[:info_type_id]
    @item_types = ItemType.find :all,:conditions=>{
      :info_type_id=>info_type_id}

    #创建map
    #    @map =GMap.new("map_div")
    #    @map.control_init(:map_type=>false,:small_zoom=>true)
    #    @map.center_zoom_init([43.46,87.36],4)
    #    marker = @GMarker.new([43.46,87.36])
    #    @map.overlay_init(marker)
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true,:map_type => true)
    @map.center_zoom_init([22.792388,79.497070],4)
    @map.overlay_init(GMarker.new([22.792388,79.497070],:title =>"India", :info_window =>"India"))
    #@map.record_init
    #@map.add_overlay(GMarker.new([22.792388, 72.421875],:title =>"Ahmedabad", :info_window =>"Ahmedabad"))
    ##以下创建满足“登陆者follow”“状态正常”两个条件的topics
    #    my_following_topics = Topic.find :all,:conditions=>{
    #      :id=>Following.find(:all,:conditions=>{:follower_id=>current_user.id}).collect{|following_topic| following_topic.topic_id}.uniq ,
    #      :status=>TOPIC_STATUS_OPEN
    #    }

    #以下是依据上述创建好的topics，即@optional_topics。
    #    @optional_topics = Array.new
    #    my_following_topics.each do |topic|
    #      if topic.if_permit_any_info_type
    #        @optional_topics << topic
    #      elsif topic.topic_info_types.nil? == false
    #        @optional_topics << topic if topic.topic_info_types.collect{|x| x.info_type_id}.member?(info_type_id)
    #      end
    #    end
    #以上是“我创建的、别人创建的但是公用的、我作为成员创建的”三种topic的集合

    @optional_topics = Topic.find_by_sql ['select * from topics where id in(select topic_id from topic_info_types where topic_id in (select topic_id from followings where follower_id =?) and info_type_id = ?) and status =?',
      current_user.id,
      info_type_id,
      1]
    #下面对这个集合再分为三类
    #
    #    @optional_topics_of_my_own
    #    @optional_topics_created_by_public
    #    @optional_topics_created_by_teams

  end
  def createtest
    info_type_id = params[:info_type_id]

    @info=Info.create(:if_commented=>params[:if_commented],
      :creator_id=>current_user.id,
      :info_type_id=>info_type_id)
    item_types =ItemType.find :all,
      :conditions=>["info_type_id = ?",info_type_id]
    error=[]
    item_types.each do |item_type|
      item_value = params["value_of_#{item_type.id}"]
      if ITEM_IS_ATTACHMENT.member? item_type.content_type_id and item_value.blank? != true
        attachment = Attachment.create(:uploaded_data=>item_value)
      else
        error<<ITEM_IS_GEO.member?(item_type.content_type_id).to_s+'@'+item_value.blank?.to_s
      end
    end
    render :text=>error.to_s
  end

  def create
    #################################
    #创建一个info实体需要做如下3件事：
    #1.创建info对象（单数）；
    #2.创建items对象（集合）；
    #3.创建items对应的attachment（集合）；
    #4.创建topic_info对象（集合）
    #5.更新topic_statistic记录
    #################################
    #1.创建info 对象，依据三个参数:if_commented、、info_type_id
    @info_type = InfoType.find params[:info_type_id].to_i

    @info=Info.create(:if_commented=>params[:if_commented],
      :creator_id=>current_user.id,
      :info_type_id=>@info_type.id)

    extra_condition_id = params[:extra_condition_id]||[]

    #利用item_type集合，创建每一个item对象实例
    item_types =@info_type.item_types
    item_types.each do |item_type|
      item_value = params["value_of_#{item_type.id}"]
      Item.create_item(item_type,item_value,@info.id,params[:latitude],params[:longitude])
    end

    #4.创建topic_info对象（集合）

    if params[:topic_id].nil?
      topic_ids = params[:selected_topics]||[]
      topic_ids.each{|topic_id| TopicInfo.create_topic_info(topic_id,@info.id,current_user.id)}
    else
      TopicInfo.create_topic_info(params[:topic_id], @info.id,current_user.id)
    end
  end

  def create1119
    #################################
    #创建一个info实体需要做如下3件事：
    #1.创建info对象（单数）；
    #2.创建items对象（集合）；
    #3.创建items对应的attachment（集合）；
    #4.创建topic_info对象（集合）
    #5.更新topic_statistic记录
    #################################
    #1.创建info 对象，依据三个参数:if_commented、、info_type_id
    info_type_id = params[:info_type_id]

    @info=Info.create(:if_commented=>params[:if_commented],
      :creator_id=>current_user.id,
      :info_type_id=>info_type_id)

    #2.根据item_value_#{item_type.id}，创建items对象集
    #所需参数为三个：
    #item_type_id，
    #info_id
    #if_attachment，来源于页面输入，集合
    #value，来源于页面输入，集合
    #extra_condition_id，来源于页面输入，集合

    extra_condition_id = params[:extra_condition_id]||[]

    #利用item_type集合，创建每一个item对象实例
    item_types =ItemType.find :all,
      :conditions=>["info_type_id = ?",info_type_id]
    item_types.each do |item_type|
      #创建 一个item对象实例，同时对应不同的item对象的特点创建其他信息。
      #一个item对象实例需要：item_type_id、info_id、value、if_attachment、extra_condition_id
      #从用户输入获取某个item_type的value
      item_value = params["value_of_#{item_type.id}"]

      #如果item是附件，先创建附件对象实例，再创建item对象实例，最后进行对象实例的参数的修改
      if ITEM_IS_ATTACHMENT.member?(item_type.content_type_id) and !item_value.blank?
        #创建attachment对象实例,sleep 1,让后台有时间计算附件的相关信息。
        attachment = Attachment.create(:uploaded_data=>item_value)
        sleep 1

        #创建item对象实例，同时将Attachment实例的id
        item = Item.create(:item_type_id=>item_type.id,
          :info_id=>@info.id,
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
          :info_id=>@info.id,
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
          :info_id=>@info.id,
          :value=>item_value,
          :content_type_id=>item_type.content_type_id#,
          #:extra_condition_id=>extra_condition_id[i]
        )
        #如果item是地理信息
      elsif ITEM_IS_GEO.member? item_type.content_type_id
        lat_lng = params[:latitude]+'$'+params[:longitude]
        item = Item.create(:item_type_id=>item_type.id,
          :info_id=>@info.id,
          :value=>lat_lng,
          :content_type_id=>item_type.content_type_id #,
          #:extra_condition_id=>extra_condition_id[i]
        )
      

      end

      #更新item的if_title属性
      if item_type.if_title
        item.update_attributes :if_title=>true
      end
    end

    #4.创建topic_info对象（集合）
    topic_ids = params[:selected_topics]||[]
    info_id = @info.id
    topic_ids.each{|topic_id| TopicInfo.create_topic_info(topic_id, info_id,current_user.id)}
  end

  def create1104
    #################################
    #创建一个info实体需要做如下3件事：
    #1.创建info对象（单数）；
    #2.创建items对象（集合）；
    #3.创建items对应的attachment（集合）；
    #4.创建topic_info对象（集合）
    #5.更新topic_statistic记录
    #################################
    #1.创建info 对象，依据三个参数:if_commented、、info_type_id
    info_type_id = params[:info_type_id]

    @info=Info.create(:if_commented=>params[:if_commented],
      :creator_id=>current_user.id,
      :info_type_id=>info_type_id)

    #2.根据item_values数组，创建items对象集
    #所需参数为三个：
    #item_type_id，
    #info_id
    #if_attachment，来源于页面输入，集合
    #value，来源于页面输入，集合
    #extra_condition_id，来源于页面输入，集合

    item_values = params[:item_values]||[]
    extra_condition_id = params[:extra_condition_id]||[]

    #找到用户选中的info_type_id对应的item_type集合
    item_types =ItemType.find :all,
      :conditions=>["info_type_id = ?",info_type_id]

    #使用item types集合，对每一类信息进行填充，实际就是对每个item 的value进行填充。
    item_types.each_index do |i|
      unless item_values[i].blank?

        #如果item是附件
        if ITEM_IS_ATTACHMENT.member? item_types[i].content_type_id
          #3.创建attachment对象实例,sleep 1,让后台有时间计算附件的相关信息。
          #设置后台处理附件的时间backend_interval，如果来不及处理，增加时间，再来一遍。最多不超过10s。

          attachment = Attachment.create(:uploaded_data=>item_values[i])
          sleep 5

          #创建item对象实例，同时将Attachment实例的id
          item = Item.create(:item_type_id=>item_types[i].id,
            :info_id=>@info.id,
            #以下语句，使用刚建立的attachment的id，作为item 的value保存
            #虽然对于图片可能需要创建几条记录，但是现在引用的时候恰是主文件的id
            :value=>attachment.id,
            :extra_condition_id=>extra_condition_id[i]
          )
          #同时更新attachment的item_id值
          attachment.update_attributes(:item_id=>item.id)

          #如果item是富文本
        elsif ITEM_IS_RICH_TEXT.member? item_types[i].content_type_id
          #2.创建item对象实例
          item = Item.create(:item_type_id=>item_types[i].id,
            :info_id=>@info.id,
            :value=>item_values[i],
            :extra_condition_id=>extra_condition_id[i]
          )

          #更新由upload_attach_file和upload_image_file最新创建attachment实例记录的item_id值
          image_files = item_values[i].scan(/<IMG.*?>/)
          attach_files = item_values[i].scan(/<A href.*?<\/A>/)

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
        elsif ITEM_IS_COMMON.member? item_types[i].content_type_id
          Item.create(:item_type_id=>item_types[i].id,
            :info_id=>@info.id,
            :value=>item_values[i],
            :extra_condition_id=>extra_condition_id[i]
          )

          #如果item是地理信息
        elsif ITEM_IS_GEO.member? item_types[i].content_type_id
          lat_lng = params[:latitude]+'$'+params[:longitude]
          Item.create(:item_type_id=>item_types[i].id,
            :info_id=>@info.id,
            :value=>lat_lng,
            :extra_condition_id=>extra_condition_id[i]
          )
        end
      else
        Item.create(:item_type_id=>item_types[i].id,
          :info_id=>@info.id
        )
      end
    end

    #4.创建topic_info对象（集合）
    topic_ids = params[:selected_topics]||[]
    info_id = @info.id
    topic_ids.each do |topic_id|
      TopicInfo.create_topic_info(topic_id, info_id,current_user.id)
      @topic_statistic = TopicStatistic.find_by_topic_id(topic_id)
      #前提是@topic_statistic.infos_quantity不能为nil，否则出错，避免方法在模型设计的时候，将此值的初始值设为0
      if @topic_statistic
        @topic_statistic.update_attributes(:infos_quantity=>@topic_statistic.infos_quantity+1)
      else
        TopicStatistic.create(:topic_id=>topic_id,:infos_quantity=>1)
      end
    end
  end


  def create_old
    #创建一个info实体需要做如下3件事：
    #1.创建info对象（单数）；
    #2.创建items对象（集合）；
    #3.创建topic_info对象（集合）

    #从new方法处得到:info_type_id这个值
    #info_type_id=session[:info_type_id],这是原来的思路，后来改为如下的hidden_field_tag方式
    #
    info_type_id = params[:info_type_id]

    #创建info 对象，依据三个参数:if_commented、、info_type_id
    @info=Info.create(:if_commented=>params[:if_commented],
      :creator_id=>current_user.id,
      :info_type_id=>info_type_id)

    #根据item_values数组，创建items对象，所需参数为三个：value、item_type_id、info_id
    item_values = params[:item_values]||[]

    item_types =ItemType.find :all,
      :conditions=>["info_type_id = ?",info_type_id]

    #使用item types集合，对每一类信息进行填充，实际就是对每个item 的value进行填充。
    n = 0
    random_filename = String.new
    item_types.each do |item_type|
      case item_type.content_type_id
      when 5,6
        Item.create(:value=>item_values[n],
          :item_type_id=>item_type.id,
          :info_id=>@info.id )
      when 3,4,7
        #如果是附件形式的信息，则需要上传附件和在value中保存信息，这个信息的形式如下：
        # "原始文件名","保存文件名","保存目录"
        #原始文件名从模型类中的get_oringinal_filename方法获得。
        #保存文件名则需要按照"日期_xxxxxxxx.原始后缀"的方式获得，8个x是随机字符串和
        #下面这段代码可以放在模型中。
        original_filename = Info.get_original_filename(item_values[n])
        original_filename =~/(.*)\.(.*)/
        original_filename_body = $1
        original_filename_suffix =$2
        #生成随机6个小写字母组成的文件名
        random_filename = Info.random_filename

        #时间标记
        time_prefix = Time.now.year.to_s+Time.now.month.to_s+Time.now.day.to_s

        #目录标记
        directory_name = 'files'

        #最终的文件存储信息
        storied_filename=String.new
        storied_filename=time_prefix+'|'+ original_filename_body+'|'+random_filename+'|'+original_filename_suffix+'|'+directory_name

        #创建items记录
        Item.create(:value=> storied_filename,
          :item_type_id=>item_type.id,
          :info_id=>@info.id )

        #在文件系统中创建文件
        Info.save_file(item_values[n],random_filename)
      end
      n+=1
    end

    optional_topic_ids = params[:optional_topic_ids]||[]
    optional_topic_ids = optional_topic_ids.uniq
    optional_topic_ids.each do |topic_id|
      if Topic.find(topic_id) !=nil
        if Topic.find(topic_id).if_verify_info ==0
          TopicInfo.create(:info_id=>@info.id,
            :topic_id=>topic_id,
            :verified=>1)
        else
          TopicInfo.create(:info_id=>@info.id,
            :topic_id=>topic_id,
            :verified=>0)
        end
      end
    end

  end

  def show
    #    @info_id = params[:id]
    #    info_type_id = Info.find(@info_id).info_type_id
    #    @item_types = ItemType.find(:all,
    #      :conditions=>["info_type_id = ?",info_type_id])
    #    @item_type_ids =@item_types.collect{|x| x.id}
    #    @items = Item.find :all,
    #      :conditions=>["item_type_id IN(?) and info_id = ?",@item_type_ids,@info_id]
    #从my_constants中获取参数，为了传递到view。
    unless params[:topic_id].blank?
      @topic = Topic.find params[:topic_id]
      @topic_info_types = @topic.topic_info_types
    end
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

    #显示评论，同时创建评论

    @comments = Comment.find(:all,
      :conditions=>["info_id = ? ",params[:id]])
    @comment = Comment.new
    render :template=>'/common/info_details',:layout=>'/layouts/zone'

  end

  def edit
    ###################################################
    # 1.获取info id之后，创建@info对象实例
    # 2.获取@info的@items集合。
    # 3.然后将items集合中的单项显示出来即可
    # 4.显示info和topic之间的关系
    # 5.
    ###################################################
    #从my_constants中获取参数，为了传递到view。
    @item_is_attachment = ITEM_IS_ATTACHMENT
    @item_is_common = ITEM_IS_COMMON
    @item_is_rich_text = ITEM_IS_RICH_TEXT
    @item_is_geo = ITEM_IS_GEO

    @info = Info.find params[:id]

    #调用info的实例方法
    @item_types = @info.item_types
    @items = @info.items_by_position_order

    #如果该信息的item中有地图信息，准备地图数据
    if @info.content_type_ids.member? 11

      @map = GMap.new("map_div")
      @map.control_init(:large_map => true,:map_type => true)
      @map.center_zoom_init(@info.item_of_content_type(11).lat_lng,4)
      @map.overlay_init(GMarker.new(@info.item_of_content_type(11).lat_lng,:title =>"India", :info_window =>"India"))
      @map.record_init @map.on_click("function(overlay,point){updateLocation(point)}")

    else 
      if @info.info_type.related_content_types('id').member? 11
        @map = GMap.new("map_div")
        @map.control_init(:large_map => true,:map_type => true)
        @map.center_zoom_init([22.792388,79.497070],4)
        @map.overlay_init(GMarker.new([22.792388,79.497070],:title =>"India", :info_window =>"India"))
        @map.record_init @map.on_click("function(overlay,point){updateLocation(point)}")        
      end
    end

    

    @available_item_types = @info.blank_item_types
    #列出“我维护的地盘”
    @maintainable_topics = current_user.topics_maintaining
    @info_related_topics = @info.topics
    
  end

  def edit1021
    
    info_id = params[:id]
    @info = Info.find info_id
    @items = @info.items

    @original_topics =[]

    @topic_infos = @info.topic_infos

    if @topic_infos != nil
      @topic_infos.each do |x|
        @original_topics << Topic.find(x.topic_id) unless Topic.find(x.topic_id).blank? == true
      end
    end

    #找到status是0或1，可以follow，同时该信息没有加入进来的topic列表。
    if @topic_ids = @topic_infos.collect{|x| x.topic_id}
      if @topic_ids.blank?
        @optional_topics = Topic.find :all,
          :conditions=>["status = ? AND if_permit_other_infos = ? ",1,1]
      else
        @optional_topics = Topic.find :all,
          :conditions=>["status = ? AND if_permit_other_infos = ? AND  id NOT IN (?)",1,1,@topic_ids]
      end
    end
  end


  def update_info
    #1.找到info 对象，依据三个参数:if_commented、、info_type_id
    @info=Info.find params[:info_id]
    @info.update_attributes :if_commented=>params[:info][:if_commented] unless params[:info].nil?

    extra_condition_id = params[:extra_condition_id]||[]

    #进行info中的item内容更新；
    @info.items.each do |item|
      item_value = params["value_of_#{item.item_type.id}"]
      item.update_item(item.item_type,item_value,@info.id,params[:latitude],params[:longitude])
    end

    #新增item,利用item_type集合，创建每一个item对象实例
    @info.blank_item_types.each do |item_type|
      item_value = params["value_of_#{item_type.id}"]
      Item.create_item(item_type,item_value,@info.id,params[:latitude],params[:longitude]) unless item_value.blank?
    end

    #4.创建topic_info对象（集合）

    if params[:topic_id].nil?
      topic_ids = params[:selected_topics]||[]
      info_id = @info.id
      topic_ids.each{|topic_id| TopicInfo.create_topic_info(topic_id, info_id,current_user.id)}
    else
      TopicInfo.create_topic_info(params[:topic_id], info_id,current_user.id)
    end
    

    #其他；
    #建立topic_info关系；
    #‘是否可以进行评论’属性修改
    @info.update_attributes :updated_at=>Time.now
  end

  def update1020
    #
    @info = Info.find(params[:id])
    @info_type_id = @info.info_type_id

    #根据item_value数组，创建item对象，所需参数为三个：value、item_type_id、info_id
    @items = @info.items
    @item_value=params[:item_value]||[]
    #    @item_types =ItemType.find :all,
    #      :conditions=>["info_type_id = ?",@info_type_id]
    0.upto(@item.length-1) do |x|
      x.update_attributes(:value=>@item_value[x])
    end

    #对原来的info对应的topic关系进行清理，也就是删除
    #然后再对选择的topic进行uniq操作
    TopicInfo.find(:all,:conditions=>["info_id",params[:id]]).each{|x| x.destroy}

    @selected_topic_ids = params[:selected_topics]||[]
    @selected_topic_ids = @selected_topics.uniq
    @selected_topic_ids.each do |topic|
      TopicInfo.create(:info_id=>@info.id,
        :topic_id=>topic,
        :verified=>1)
    end


  end

  def update_info0
    #是update的实现版
    #更新内容是选择信息的条目的value值
    #
    @info = Info.find(params[:id])

    #根据items对象集，修改value值
    @items = @info.items
    item_value=params[:item_values]||[]

    n=0
    @items.each do |item|
      case Info.get_content_type_id(item)
      when 5,6
        item.update_attributes(:value=>item_value[n])
      when 3,4,7
        #如果此类附件信息没有发生变化，则不需要在数据库、文件系统进行相关信息的更正
        if item_value[n].blank? == false
          random_filename = Info.random_filename
          original_filename = Info.get_original_filename(item_value[n])
          original_filename =~/(.*)\.(.*)/
          original_filename_body = $1
          original_filename_suffix =$2
          #生成随机8个小写字母组成的文件名
          #时间标记
          time_prefix = Time.now.year.to_s+Time.now.month.to_s+Time.now.day.to_s

          #目录标记
          directory_name = 'files'

          #最终的文件存储信息
          storied_filename= String.new
          storied_filename=time_prefix+'|'+ original_filename_body+'|'+random_filename+'|'+original_filename_suffix+'|'+directory_name

          #创建items记录
          item.update_attributes(:value=> storied_filename)

          #在文件系统中创建文件,如果没有更新，item_value将会是空值，就
          Info.save_file(item_value[n],random_filename)
        end
      end
      n+=1
    end

    #对原来的info对应的topic关系进行清理，也就是删除
    TopicInfo.find(:all,:conditions=>["info_id = ?",@info.id]).each{|x| x.destroy}

    #然后再对选择的topic进行uniq操作

    selected_topic_ids = params[:selected_topics]||[]
    selected_topic_ids.each do |topic_id|
      if topic_id.blank? == false
        TopicInfo.create(:info_id=>@info.id,
          :topic_id=>topic_id,
          :verified=>1)
      end
    end
  end

  def destroy
    @info = Info.find(params[:id])
    #
    #删除的顺序是：topic_infos => items => infos
    #    @info.topic_infos.each{|x| x.destroy}
    #    @info.items.each{|x| x.destroy}
    #    @info.destroy
    #    redirect_to :action => 'get_my_topics'
    @info.destroy
    redirect_to :back
  end

  #删除内容包括三种：topic_infos/items/infos中的三个记录
  #删除的顺序是：topic_infos => items => infos
  #在infos模型类中创建一个通用方法：delete_files_from_item
  #在删除item的时候，注意三点：一是在库中删除与info关联的所有item；二是如果这个item的值
  #是附件类型，则需要删除文件。
  def delete_info
    @info = Info.find(params[:id])

    @info.topic_infos.each{|x| x.destroy}

    @info.items.each do |item|
      c = Info.get_content_type_id(item)
      #3，4，7是content_type_id都是附件类型，遇到附件类型
      #需要到文件系统中删除文件，避免留下垃圾。
      if c==3 or c==4 or c==7
        Info.delete_files_from_item(item,"public/files")
        item.destroy
      else
        item.destroy
      end
    end
    @info.destroy
    redirect_to :controller=>'infos',:action => 'get_my_infos'
  end

  def add_attachment
    render :partial => 'add_attachment'
  end

  def list_info_types
    @info_types =InfoType.find :all
  end

  def send_file_to_user
    send_file RAILS_ROOT+"/public"+Attachment.find(params[:attachment_id]).public_filename unless Attachment.find(params[:attachment_id]).nil?
  end

  def upload_editor_image
    backend_interval = 1
    image_file = Attachment.create :uploaded_data=>params[:imgfile]
    sleep backend_interval
    render :text => %Q"
      <script>
        window.parent.LoadIMG('#{image_file.public_filename}')
      </script>
    "
  end

  def upload_editor_attach
    attach_file = Attachment.create :uploaded_data=>params[:attach]
    render :text => %Q"
      <script>
        window.parent.LoadAttach('#{attach_file.public_filename}')
      </script>
    "
  end

  def verify_topic_info
    if params[:verify_id].to_i ==0
      TopicInfo.find_by_info_id_and_topic_id(params[:info_id],params[:topic_id]).destroy
    elsif params[:verify_id].to_i ==1
      TopicInfo.find_by_info_id_and_topic_id(params[:info_id],params[:topic_id]).update_attributes(:verified=>true)
    end
    redirect_to :back
  end
end

