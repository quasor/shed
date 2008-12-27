class TasksController < ApplicationController
  # GET /tasks
  # GET /tasks.xml
  def index
    unless params[:filter].blank?
      unless params[:filter][:user_id].blank?
        session[:user_id] = params[:filter][:user_id]
      end
    end
    @root = Task.root # replace this later with a local root
    @tasks = []
    @durations = []
    
    unless @root.nil?
      @tasks = @root.full_set

      # Compute start times for each task
      @end_date = Date.today

      user_end_dates = {}
      @tasks.each do |task|
        unless task.user.nil?
          user_end_dates[task.user.id] ||= Date.today
          task.start = user_end_dates[task.user.id]
          user_end_dates[task.user.id] = user_end_dates[task.user.id].work_day(task.estimate)
        else 
          task.start = Date.today
        end
        #task.save
      end

      @durations = Rails.cache.fetch("duration_for_#{@root.cache_key}-#{Task.count}-#{Task.last.id}#{Time.now}") do 
        durations = []
        100.times do |i|
          duration = @root.full_set.collect(&:monte_estimate).sum
          durations.push duration
        end
        durations.sort!
      end 
    end
    
    @total_calendar_days = @durations.last + (@durations.last / 7 * 2)
    
    if Release.count == 0
      flash[:warning] = 'Your schedule is empty'
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    @task = Task.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
  end

  # POST /tasks
  # POST /tasks.xml
  def create
    @task = Task.new(params[:task])

    respond_to do |format|
      if @task.save
        unless (params[:parent_id].blank?)
          @task.move_to_child_of(Task.find(params[:parent_id]))
        end
        flash[:notice] = 'Task was successfully created.'
        format.html { redirect_to(tasks_url(:p => params[:parent_id] ? params[:parent_id].to_i : nil)) }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update
    @task = Task.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(params[:task])
        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to(tasks_url(:p => params[:parent_id] ? params[:parent_id].to_i : nil)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to(tasks_url) }
      format.xml  { head :ok }
    end
  end
  
  def bulk
    @text = params[:tasks]
    @rows = @text.split("\n").collect {|t| t.split(',') }
    @tasks = []
    
    @rows.collect do |r|
      if r.size > 4
        task = {
          :user     => r[0],
          :section  => r[1],
          :title    => r[2],
          :low      => r[3],
          :high     => r[4],
        }
        logger.info task.inspect
        @low = r[3]
        @project = Task.find params[:project_id]
        unless @project.nil? || @low.blank?
          @user = User.find_by_name r[0]
          @user_id = @user.id unless @user.nil?
          @task = Task.new(:title => r[2], :low => r[3], :high => r[4], :user_id => @user_id)
          @task.tag_list = r[1] unless r[1].blank?
          @task.save! 
          @task.move_to_child_of(@project)
          flash[:notice] = 'Tasks were successfully created.'
        else
          flash[:notice] = 'Tasks were not created.'
        end
      end
    end
    redirect_to root_path
  end 

  # meuselect is the id of currently selected menu
    def showmenu(menuselect)
      if menuselect
        @menuselect = Task.find(menuselect.to_i)
        selectpath = @menuselect.self_and_ancestors
      else
        @menuselect = nil
        selectpath = []
      end
      parents = (selectpath.map{|m| m.parent}+[@menuselect]).uniq-[nil]
      parents_sql_filter = parents.empty? ? '' : " OR parent_id IN (#{parents.map{|p| p.id}.join(',')})"

      # retrieve only the menus that need to be open
      allmenus = Task.find(:all, :conditions => "(parent_id IS NULL #{parents_sql_filter})", :order => 'lft')
      # mark where to open and close html lists
      @menus = []
      allmenus.each_index { |i|
          @menus[i] = {:indent => allmenus[i].level, 
                       :title  => allmenus[i].title,
                       :children_count => allmenus[i].all_children_count,
                       :id => allmenus[i].id,
                       }
          @menus[i][:selected] =  allmenus[i] == @menuselect
      }
        allmenus[1..-1].each_index { |i|
          @menus[i][:open] = @menus[i][:indent] > @menus[i-1][:indent]
          @menus[i][:close] = [0, @menus[i][:indent] - @menus[i+1][:indent]].max
        }
      @menus.first[:open] = true 
      @menus.last[:open] = false
      @menus.first[:close] = 0
      @menus.last[:close] = 1

    end
end


