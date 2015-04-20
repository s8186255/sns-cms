class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem
  before_filter :info_of_user
  layout 'my'

  def list_maintainers
    @topic = Topic.find params[:topic_id]
    @users=@topic.maintainers(0)
    @choic = 1
    render :template=>'users/list_users'
  end

  def show_real_user
    @real_user = User.find(params[:user_id]).real_user
    if @real_user.nil?
      render :text=>"用户没有留下真实信息，建议不要接受",:layout=>'my'
    end
  end
  def list_followers
    @topic = Topic.find params[:topic_id]
    @users=@topic.followers(1)
    @choic = 2
    render :template=>'users/list_users'
  end

  def edit_current_user
    @user=User.find current_user.id
    render :template=>'/users/edit'
  end

  def update
    if current_user.update_attributes(params[:user])
      redirect_to '/my'
    else
      #render :text=>"#{params[:user]}"#:action => 'edit'
    end
  end

  #用户详细信息
  def show
  case params[:verify_type]
  when 'm'
    @maintaining = Maintaining.find params[:id]
    @user = ExtUser.find @maintaining.maintainer_id
    render :template=>'/common/user_details'
  when 'f'
    @following = Following.find params[:id]
    @user = ExtUser.find @following.follower_id
    render :template=>'/common/user_details'
  else
    redirect_to '/'
    end
  end
end
