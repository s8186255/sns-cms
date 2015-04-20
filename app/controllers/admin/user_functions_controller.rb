class Admin::UserFunctionsController < ApplicationController
  # GET /user_functions
  # GET /user_functions.xml
  def index
    @user_functions = UserFunction.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_functions }
    end
  end

  # GET /user_functions/1
  # GET /user_functions/1.xml
  def show
    @user_function = UserFunction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_function }
    end
  end

  # GET /user_functions/new
  # GET /user_functions/new.xml
  def new
    @user_function = UserFunction.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => [:admin,@user_function] }
    end
  end

  # GET /user_functions/1/edit
  def edit
    @user_function = UserFunction.find(params[:id])
  end

  # POST /user_functions
  # POST /user_functions.xml
  def create
    @user_function = UserFunction.new(params[:user_function])

    respond_to do |format|
      if @user_function.save
        flash[:notice] = 'UserFunction was successfully created.'
        format.html { redirect_to([:admin,@user_function]) }
        format.xml  { render :xml => @user_function, :status => :created, :location => @user_function }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_function.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_functions/1
  # PUT /user_functions/1.xml
  def update
    @user_function = UserFunction.find(params[:id])

    respond_to do |format|
      if @user_function.update_attributes(params[:user_function])
        flash[:notice] = 'UserFunction was successfully updated.'
        format.html { redirect_to([:admin,@user_function]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_function.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_functions/1
  # DELETE /user_functions/1.xml
  def destroy
    @user_function = UserFunction.find(params[:id])
    @user_function.destroy

    respond_to do |format|
      format.html { redirect_to(admin_user_functions_url) }
      format.xml  { head :ok }
    end
  end
end
