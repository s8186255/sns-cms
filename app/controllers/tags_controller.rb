# To change this template, choose Tools | Templates
# and open the template in the editor.

class TagsController < ApplicationController
  def index
    @tags = Tag.find(:all,:order => "created_at desc")
  end

  def add
    Tag.create(:name => params[:name])
    @tags = Tag.find(:all, :order => "created_at desc")
    render :partial => "tags", :locals => {:tags => @tags}
  end
end
