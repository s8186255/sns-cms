class AttachmentsController < ApplicationController
  def new
    @attachment = Attachment.new
  end

  def create
    #    @attachment = Attachment.new(params[:asset])
    #    respond_to do |format|
    #      if @attachment.save
    #        flash[:notice] = '图像已经成功上传'
    #        format.html { redirect_to(@attachment) }
    #        format.xml  { head :created, :location => asset_url(@attachment) }
    #      else
    #        format.html { render :action => "new" }
    #        format.xml  { render :xml => @attachment.errors.to_xml }
    #      end
    #    end
    @attachable_file = Attachment.new(params[:attachment])
    if @attachable_file.save
      flash[:notice] = 'Attachment was successfully created.'
      #redirect_to attachable_url(@attachable_file)
    else
      flash[:notice] = 'Attachment is failure.'
    end
  end

end
