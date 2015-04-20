# To change this template, choose Tools | Templates
# and open the template in the editor.

module MyConstants

  ########################
  #与topic模型相关的常量定义
  ########################

  #status常量
  TOPIC_STATUS_CLOSE = 0    #关闭状态
  TOPIC_STATUS_OPEN = 1     #正常状态
  TOPIC_STATUS_DELETED = 2  #删除状态

  #if_verify_info常量
  TOPIC_IF_VERIFY_INFO_NO = false  #不需要验证信息
  TOPIC_IF_VERIFY_INFO_YES = true  #需要验证信息

  #following_mode常量
  TOPIC_FOLLOWING_MODE_PUBLIC = 1  #public，允许任何人follow
  TOPIC_FOLLOWING_MODE_MEMBER = 2  #member，需要创建者验证用户的follow申请
  TOPIC_FOLLOWING_MODE_PRIVATE = 0  #private，自己follow。

  #maintaining_mode常量
  TOPIC_MAINTAINING_MODE_PUBLIC = 1  #public，任何人可以进行topic相关操作，如新加入信息、审核信息等；
  TOPIC_MAINTAINING_MODE_MEMBER = 2  #member，只有申请人得到许可，方可加入到topic的维护中。
  TOPIC_MAINTAINING_MODE_PRIVATE = 0  #private，只是自己在维护






  ##########################
  #定义topic_info参数
  ##########################
  VERIFIED_IS_FALSE = false
  VERIFIED_IS_TRUE = true



  #定义function_id

  #定义topic type相关的参数
  #共十种topic type
  #定义公众可以follow的topic数组
  #PUBLIC_OPTIONAL_TOPIC_IDS =[1,2,3,4,5,6]

  #############################
  #定义team和topic之间的关系
  #############################
  EDIT_OPERATION_ID = 1
  FOLLOW_OPERATION_ID = 2

  #############################
  #定义info相关的常量
  #############################
  
  #定义是否允许评论
  PERMIT_COMMENT = 1
  PROHIBIT_COMMENT = 0
  FREEZE_COMMENT =2

  #定义score的显示
  INFO_EXCELLENT = '太棒了'
  INFO_GOOD = '不错'
  INFO_COMMON = '一般'
  INFO_POOR = '差劲'
  INFO_TOO_BAD = '太差了'

  #定义score的分数
  INFO_IS_EXCELLENT = 5
  INFO_IS_GOOD = 4
  INFO_IS_COMMON = 3
  INFO_IS_POOR = 2
  INFO_IS_TOO_BAD = 1


  ############################################
  #定义item模型相关常量
  #内容是附件和非附件的数组常量，目的是创建不同的输入界面
  ############################################
  #定义信息录入时的常量
  ITEM_IS_ATTACHMENT = [3,4,7,9,12]
  ITEM_IS_COMMON = [5,6,10]
  ITEM_IS_RICH_TEXT = [8]
  ITEM_IS_GEO =[11]

  #定义显示时的常量（和上述内容日后要合并）
  ITEM_IS_VIDEO_FOR_SHOW = 3
  ITEM_IS_AUDIO_FOR_SHOW = 4
  ITEM_IS_PURE_TEXT_FOR_SHOW = 5
  ITEM_IS_DIGITAL_FOR_SHOW = 6
  ITEM_IS_IMG_FOR_SHOW = 7
  ITEM_IS_RICH_TEXT_FOR_SHOW = 8
  ITEM_IS_ATTACHMENT_FOR_SHOW = 9
  ITEM_IS_CODE_FOR_SHOW = 10
  ITEM_IS_GEO_FOR_SHOW = 11
  ITEM_IS_FLASH_FOR_SHOW = 12

  ################
  #列表topic的类型
  ################
  TOPIC_LIST_CREATED = 1
  TOPIC_LIST_MAINTAINING = 2
  TOPIC_LIST_FOLLOWING = 3


end
