class PicturesController < ApplicationController
  # GET /pictures
  # GET /pictures.xml
  caches_page :show,:thumb
  def index
    @pictures = Picture.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pictures }
    end
  end

  # GET /pictures/1
  # GET /pictures/1.xml
  def show
    @picture = Picture.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.png  { render :inline => "@picture.operate{}", :type => :flexi}
      format.gif  { render :inline => "@picture.operate{}", :type => :flexi}
      format.jpg  { render :inline => "@picture.operate{}", :type => :flexi}
      format.xml  { render :xml => @picture }
    end end

  # GET /pictures/new
  # GET /pictures/new.xml
  def new
    @picture = Picture.new
  end

  # GET /pictures/1/edit
  def edit
    @picture = Picture.find(params[:id])
  end

  def create
    @picture = Picture.new(params[:picture])

    respond_to do |format|
      if @picture.save
        flash[:notice] = 'Picture was successfully created.'
        format.html { redirect_to(@picture) }
        format.xml  { render :xml => @picture, :status => :created, :location => @picture }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @picture.errors, :status => :unprocessable_entity }
      end
    end
  end

  # POST /pictures
  # POST /pictures.xml

  # PUT /pictures/1
  # PUT /pictures/1.xml
  def update
    @picture = Picture.find(params[:id])

    respond_to do |format|
      if @picture.update_attributes(params[:picture])
        flash[:notice] = 'Picture was successfully updated.'
        format.html { redirect_to(@picture) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @picture.errors, :status => :unprocessable_entity }
      end
    end
    expire_picture(@picture)
  end

  # DELETE /pictures/1
  # DELETE /pictures/1.xml
  def destroy
    @picture = Picture.find(params[:id])
    @picture.destroy

    respond_to do |format|
      format.html { redirect_to(pictures_url) }
      format.xml  { head :ok }
    end
    expire_picture(@picture)
  end

  def thumb
    @picture = Picture.find(params[:id])
    render :inline=>"@picture.operate{|p| p.resize 30}",:type=>:flexi
  end
  private
  def expire_picture(picture)
    expire_page formatted_picture_path(picture, :jpg)
  end
end
