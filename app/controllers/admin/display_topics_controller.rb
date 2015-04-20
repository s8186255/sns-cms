class Admin::DisplayTopicsController < ApplicationController
  before_filter :login_required
  before_filter :return_if_not_admin
  layout "admin"

  def index
  end

  def new
    @display_topic=DisplayTopic.new
  end

  def create
    @display_topic = DisplayTopic.new(params[:display_topic])
    @display_topic.referee_id = current_user.id
    @display_topic.verifier_id = current_user.id
    @display_topic.save
    #    respond_to do |format|
    #      if @display_topic.save
    #        flash[:notice] = 'Role was successfully created.'
    #        format.html { redirect_to([:admin,@display_topic]) }
    #        format.xml  { render :xml => @display_topic, :status => :created, :location => @display_topic }
    #      else
    #        format.html { render :action => "new" }
    #        format.xml  { render :xml => @display_topic.errors, :status => :unprocessable_entity }
    #      end
    #    end
  end

  def destroy
  end

  def edit
  end

  def update
  end

  def show
  end

end
