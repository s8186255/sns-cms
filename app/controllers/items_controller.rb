class ItemsController < ApplicationController
  
  before_filter :login_required
  def index
    @items=Item.find :all
  end

  def new
  end

  def create
    if Item.create(params[:item])
      redirect_to :action=>'index'
    else
      redirect_to :action=>'new'
    end
  end

  def show
    @item=Item.find(params[:id])
  end

  def update
    @item= Item.find(params[:id])
    if @item.update_attributes(params[:item])
      redirect_to :action => 'show', :id => @item
    else
      render :action => 'edit'
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    redirect_to :action => 'index'
  end

  def edit
    @item=Item.find(params[:id])
  end

end
