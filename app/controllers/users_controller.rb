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

	def mytasks
		redirect_to user_path(current_user)
	end
	
  # GET /users/1
  # GET /users/1.xml
  # display the user's timers
  def show
		@title = "My Tasks"
    @user = User.find(params[:id])
    #@timer = !params[:timer].blank?

    unless @user == current_user || admin?
      returning redirect_to(current_user)
    end
		@conditions = { :parent_id => params[:project] } unless params[:project].blank?
    @tasks = current_user.tasks.find :all,  :conditions => @conditions, :order => :position
		#@tasks = Task.all :all, :conditions => {:type => nil }, :order => :position
    @tasks.delete_if {|t| (t.user_id != @user.id || (t.completed? && !t.touched_today?)) && t.type.nil? }   
		@tasks.delete_if { |t| ((t.completed? && !t.touched_today?)) && t.type.nil? } 
    @project_ids = @tasks.collect { |t| t.parent_id }.uniq
    @tasks.delete_if {|t| !t.type.nil? || t.root? }   
		
		#pos = 1
		#for task in @tasks
		#	unless task.in_list? 
		#	task.insert_at(pos)	
		#	pos = pos + 1
		#	end
		#end

		@this_sunday = Date.today - Date.today.cwday
		
    #@tasks.delete_if {|t| t.type.nil? && (t.start.to_date > Date.today  + 1.week) }   		

    # find all open intervals not for this task and close them
    @intervals = current_user.intervals.find(:all, :conditions => {:end => nil})      
    @interval = current_user.active_intervals.first
    @current_task = @interval.task unless @interval.nil?
    
		# timer code
    unless params[:task_id].blank?
      @task = current_user.tasks.find(params[:task_id]) 
      @interval = @task.intervals.active.first    
      if @interval.nil?
        @interval = Interval.new(:start => DateTime.now, :user_id => current_user.id) 
        @task.intervals << @interval
      end 
      @current_task = @task
    end

		@intervals = current_user.intervals
    @intervals = @intervals - [@interval] if params[:stop] != "true" 
		if params[:stop] == "true"
	    @current_task = nil  
	    @intervals = current_user.intervals(true).find(:all, :conditions => {:end => nil})      
	    @intervals.each {|i| i.end = DateTime.now;i.save! }
		end

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
