class Admin::FeeRecordsController < ApplicationController
  # GET /fee_records
  # GET /fee_records.xml
  def index
    @fee_records = FeeRecord.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fee_records }
    end
  end

  # GET /fee_records/1
  # GET /fee_records/1.xml
  def show
    @fee_record = FeeRecord.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fee_record }
    end
  end

  # GET /fee_records/new
  # GET /fee_records/new.xml
  def new
    @fee_record = FeeRecord.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fee_record }
    end
  end

  # GET /fee_records/1/edit
  def edit
    @fee_record = FeeRecord.find(params[:id])
  end

  # POST /fee_records
  # POST /fee_records.xml
  def create
    @fee_record = FeeRecord.new(params[:fee_record])

    respond_to do |format|
      if @fee_record.save
        flash[:notice] = 'FeeRecord was successfully created.'
        format.html { redirect_to([:admin,@fee_record]) }
        format.xml  { render :xml => @fee_record, :status => :created, :location => @fee_record }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fee_record.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /fee_records/1
  # PUT /fee_records/1.xml
  def update
    @fee_record = FeeRecord.find(params[:id])

    respond_to do |format|
      if @fee_record.update_attributes(params[:fee_record])
        flash[:notice] = 'FeeRecord was successfully updated.'
        format.html { redirect_to([:admin,@fee_record]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fee_record.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /fee_records/1
  # DELETE /fee_records/1.xml
  def destroy
    @fee_record = FeeRecord.find(params[:id])
    @fee_record.destroy

    respond_to do |format|
      format.html { redirect_to(admin_fee_records_url) }
      format.xml  { head :ok }
    end
  end
end
