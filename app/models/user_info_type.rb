class UserInfoType < ActiveRecord::Base
  belongs_to :user

  def self.info_types_of_logon_user(user)
    user.user_info_types
  end
  def self.info_type_ids_of_logon_user(user)
    return user.user_info_types.collect{|user_info_type| user_info_type.info_type_id}
  end

  def self.update_user_info_types(user,user_select_info_type_ids)
    #获取用户现有的应用
    user_info_type_ids = UserInfoType.info_type_ids_of_logon_user(user)
    #获取需要删除的应用和需要新建的应用。
    user_info_type_ids_create = user_select_info_type_ids - user_info_type_ids
    user_info_type_ids_delete = user_info_type_ids - user_select_info_type_ids
    #新建用户应用关系
    user_info_type_ids_create.each{|info_type_id| UserInfoType.create(:user_id=>user.id,:info_type_id=>info_type_id)} unless user_info_type_ids_create.blank?
    #删除用户应用关系
    user_info_type_ids_delete.each{|info_type_id| UserInfoType.find_by_user_id_and_info_type_id(user.id,info_type_id).destroy} unless user_info_type_ids_delete.blank?

  end
end
