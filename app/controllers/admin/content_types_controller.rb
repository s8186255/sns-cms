class Admin::ContentTypesController < ApplicationController
  before_filter :login_required
  before_filter :return_if_not_admin
  layout "admin"
  def index
    return_if_not_admin
    @content_types=ContentType.find :all
  end

  def new
  end

  def create
    if ContentType.create(params[:content_type])
      redirect_to :action=>'index'
    else
      redirect_to :action=>'new'
    end
  end

  def show
    @content_type=ContentType.find(params[:id])
  end

  def update
    @content_type= ContentType.find(params[:id])
    if @content_type.update_attributes(params[:content_type])
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @content_type = ContentType.find(params[:id])
    @content_type.destroy
    redirect_to :action => 'index'
  end

  def edit
    @content_type=ContentType.find(params[:id])
  end

end
