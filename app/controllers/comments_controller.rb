class CommentsController < ApplicationController
  before_filter :login_required
  uses_tiny_mce

  def new
    #@info_id_for_comment=Info.find(params[:id]).id
    @comment=Comment.new
  end

  def create
    comment = Comment.create(params[:comment])
    comment.update_attributes :creator_id=>current_user.id,:info_id=>params[:info_id]
      
    
  end
end
