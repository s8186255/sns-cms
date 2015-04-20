class Admin::UsersController < ApplicationController
  
  before_filter :login_required
  before_filter :return_if_not_admin
  layout "admin"
  def index
    @users=User.find :all
  end

  def new
    @map =GMap.new('map_div')
    @map.control_init(:large_map => true,:map_type => true)
    @map.center_zoom_init([43.88186397848956,87.56187200546264],14)
    @map.overlay_init(GMarker.new([43.88186397848956,87.56187200546264],:title =>"新疆", :info_window =>"新疆"))

    @map.record_init @map.on_click("function(overlay,point){updateLocation(point)}")
  end

  #  def create
  #    if User.create(params[:user])
  #      redirect_to :action=>'index'
  #    else
  #      redirect_to :action=>'new'
  #    end
  #  end

  def create
    #cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      #      self.current_user = @user
      #@user.update_attributes(:activated_at=>true)
      @user.activate
      @user.user_geo_position = UserGeoPosition.create(:latitude=>params[:latitude],:longitude=>params[:longitude])
      @user.user_avatar = UserAvatar.create(:uploaded_data=>params[:user_avatar])
      
      sleep 1
      redirect_to "/infos"
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end

  def show
    @user=User.find(params[:id])
  end

  def edit
    @user=User.find(params[:id])
  end

  def update

    @user= User.find(params[:id])
    if @user.update_attributes(params[:user])
      # redirect_to :action => 'show', :id => @user
    else
      #render :text=>"#{params[:user]}"#:action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to :action => 'index'
  end
  
  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end

end
