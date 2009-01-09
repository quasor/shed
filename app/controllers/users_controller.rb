require 'digest/sha1'
class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  before_filter :login_required
  before_filter :authorized, :except => [:show]
  def index
    @users = User.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  # display the user's timers
  def show
    @user = User.find(params[:id])
    @timer = !params[:timer].blank?

    unless @user == current_user || admin?
      returning redirect_to(current_user)
    end

    @tasks = Task.root.descendants
    @tasks.delete_if {|t| (t.user_id != @user.id || task.completed?) && t.type.nil? }   
        
    # find all open intervals not for this task and close them
    @intervals = current_user.intervals.find(:all, :conditions => {:end => nil})      
    @interval = current_user.active_intervals.first
    @current_task = @interval.task unless @interval.nil?
    

    unless params[:task_id].blank?
      @task = current_user.tasks.find(params[:task_id]) 
      @interval = @task.intervals.active.first    
      if @interval.nil?
        @interval = Interval.new(:start => DateTime.now, :user_id => current_user.id) 
        @task.intervals << @interval
      end 
      @current_task = @task
    end

    @intervals = @intervals - [@interval] if params[:stop].blank?
    @intervals.each {|i| i.end = DateTime.now;i.save! }

    flash[:notice] = ''

    unless params[:task_id].blank?
      redirect_to current_user
    else
      respond_to do |format|
        format.html {} 
        format.xml  { render :xml => @user }
      end
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end
