class UserInfoTypesController < ApplicationController
  before_filter :login_required
  before_filter :info_of_user
  layout "my"

  def edit_user_info_types
    #获取信息工具集合，来源于info_types
    #获取登录用户的已经订制的工具集合，来源于user_info_types
    @info_types = InfoType.find :all
    @user_info_type_ids=UserInfoType.info_type_ids_of_logon_user(current_user)
  end

  def update_user_info_types
    #获取用户选择的应用，并将应用的id转为整数
    selected_info_type_ids = params[:info_type]||[]
    selected_info_type_ids = selected_info_type_ids.collect{|id| id.to_i}.uniq
    UserInfoType.update_user_info_types(current_user,selected_info_type_ids)
  end
end
