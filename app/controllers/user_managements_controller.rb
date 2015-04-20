class UserManagementsController < ApplicationController
  before_filter:login_required
  before_filter :info_of_user
  layout 'my'

  def new
    @map =GMap.new('map_div')
    @map.control_init(:large_map => true,:map_type => true)
    @map.center_zoom_init([43.88186397848956,87.56187200546264],14)
    @map.overlay_init(GMarker.new([43.88186397848956,87.56187200546264],:title =>"新疆", :info_window =>"新疆"))

    @map.record_init @map.on_click("function(overlay,point){updateLocation(point)}")
  end

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
  


end
