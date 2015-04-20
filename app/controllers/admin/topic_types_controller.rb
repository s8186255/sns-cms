class Admin::TopicTypesController < ApplicationController
  
  before_filter :login_required

  before_filter :return_if_not_admin
  def index
    @topic_types=TopicType.find :all
  end

  def new
  end

  def create
    @topic_type = TopicType.create(params[:topic_type])
  end

  def show
    @topic_type=TopicType.find(params[:id])
  end

  def edit
    @topic_type=TopicType.find(params[:id])
  end

  def update
    @topic_type=TopicType.find(params[:id])
    @topic_type.update_attributes(params[:topic_type])
  end

  def destroy
    @topic_type = TopicType.find(params[:id])
    @topic_type.destroy
    redirect_to :action => 'index'
  end




end
