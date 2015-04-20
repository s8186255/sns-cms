class TopicTypesController < ApplicationController
  # GET /topic_types
  # GET /topic_types.xml
  before_filter :login_required
  layout 'my'
  def index
    @topic_types = TopicType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @topic_types }
    end
  end

  # GET /topic_types/1
  # GET /topic_types/1.xml
  def show
    @topic_type = TopicType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @topic_type }
    end
  end

  # GET /topic_types/new
  # GET /topic_types/new.xml
  def new
    @topic_type = TopicType.new
    @my_topic_types = current_user.topic_types
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @topic_type }
    end
  end

  # GET /topic_types/1/edit
  def edit
    @topic_type = TopicType.find(params[:id])
  end

  # POST /topic_types
  # POST /topic_types.xml
  def create
    @topic_type = TopicType.new(params[:topic_type])

    respond_to do |format|
      if @topic_type.save
        flash[:notice] = 'TopicType was successfully created.'
        format.html { redirect_to(@topic_type) }
        format.xml  { render :xml => @topic_type, :status => :created, :location => @topic_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @topic_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /topic_types/1
  # PUT /topic_types/1.xml
  def update
    @topic_type = TopicType.find(params[:id])

    respond_to do |format|
      if @topic_type.update_attributes(params[:topic_type])
        flash[:notice] = 'TopicType was successfully updated.'
        format.html { redirect_to(@topic_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @topic_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /topic_types/1
  # DELETE /topic_types/1.xml
  def destroy
    @topic_type = TopicType.find(params[:id])
    @topic_type.destroy

    respond_to do |format|
      format.html { redirect_to(topic_types_url) }
      format.xml  { head :ok }
    end
  end
end
