class TasksController < ApplicationController
  # GET /tasks
  # GET /tasks.xml
  before_filter :login_required
  def index
    @day_in_pixels = 10
    
    unless params[:filter].blank?
      unless params[:filter][:user_id].blank?
        session[:user_id] = params[:filter][:user_id]
      end
    end
   
   rebuild_schedule(params[:force] == "true") 
   
   unless params[:u].blank?
     user_id = params[:u].to_i
     @tasks.delete_if {|t| t.user_id != user_id && t.type.nil? }   
   end

   unless params[:p].blank?
     project_id = params[:p].to_i
     @tasks.delete_if {|t| t.parent_id != project_id && t.type.nil? }   
   end
    
    if Release.count == 0
      flash[:warning] = 'Your schedule is empty'
    else
      flash[:notice] = "Last updated at #{Task.root.updated_at.to_s()}"
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

  def reorder
    @order = params[:order].scan(/\d+/)
    unless @order.empty?
      @order.each do |id|
        task = Task.find id
        task.move_to_bottom
      end
    end
    t = Task.root
    t.updated_at = Time.now
    t.save
    
    rebuild_schedule
    
    render :update do |page|
      page.replace_html 'flash', :partial => 'refresh'
    end
  end

  def bulk_new
  end 

  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    @task = Task.new
    @task.user = current_user

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
    @task = current_user.tasks.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(params[:task] || params[:project])
        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to(tasks_url(:p => params[:parent_id] ? params[:parent_id].to_i : nil)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def complete
    @task = current_user.tasks.find(params[:id])
    @task.intervals.active.each {|i| i.end = DateTime.now;i.save! }

    respond_to do |format|
      if @task.update_attributes(params[:task] || params[:project])
        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to(user_path(current_user, :timer => true)) }
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
      if r.size > 3
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
          @user = User.find_by_name(r[0].strip) || User.find_by_login(r[0].strip)
          @user_id = @user.id unless @user.nil?
          @task = Task.new(:title => r[2].strip, :low => r[3], :high => r[4], :user_id => @user_id)
          @task.tag_list = r[1] unless r[1].blank?
          @task.save! 
          @task.move_to_child_of(@project)
          flash[:notice] = 'Tasks were successfully created.'
        else
          flash[:notice] = 'Tasks were not created:<br>' + params[:tasks]
        end
      else
        flash[:notice] = 'Tasks were not created (not enough)<br>' + params[:tasks] + '<br>' + @rows.inspect
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
    private
    
    def run_simulation
      durations = []
      #Projection.destroy_all
      projection_collection = {}
      100.times do |i|
        # walk the schedule once
        user_end_dates = {}
        projections={}
        tasks = Task.root.full_set
        tasks.each do |task|
          unless task.user.nil? || task.completed? 
            user_end_dates[task.user.id] ||= Date.today.work_day(0)
            task.start = user_end_dates[task.user.id].work_day(0)
            task_end = user_end_dates[task.user.id] = user_end_dates[task.user.id].work_day(task.monte_estimate)
            projections[task.id] = Projection.new(:start => task.start, :end => task_end) if task.type.nil?
            # task.projections << 
          else 
            task.start = Date.today
          end
        end
        # use the estimates from the simulation to determine the end date of the project
        Project.all.each do |project|
          #project.projections.destroy_all
          projection_collection[project.id] ||= []
          max_end_date = project.children.collect { |c| projections[c.id] }.flatten.compact.collect(&:end).max
          #flatten.max
          projection_collection[project.id].push max_end_date
        end

        durations.push (user_end_dates.values.max - Date.today)

      end
      projection_collection.each_pair do |k,v|
        v.compact!
        v.sort! 
        logger.info "!!!!!#{v.size} dates #{v.join "\n"}"
        Projection.create(:task_id => k, :start => v[10], :end => v[95])
      end
      
    end
    def rebuild_schedule(force = false)
       @root = Task.root # replace this later with a local root

        @total_calendar_days = 0

        unless @root.nil?
          suffix = force ? Time.now.to_s : ""
          @tasks = Rails.cache.fetch("tasks__#{@root.cache_key}-#{Task.count}-#{Task.last.id}#{Date.today}"+suffix) do
            user_end_dates = {}
            tasks = []
            @tasks_raw = Task.root.full_set
            # Compute start times for each task
            @tasks_raw.each do |task|
              unless task.user.nil? || task.completed? 
                user_end_dates[task.user.id] ||= Date.today.work_day(0)
                task.start = user_end_dates[task.user.id].work_day(0)
                task.end = user_end_dates[task.user.id] = user_end_dates[task.user.id].work_day(task.estimate)
                task.save
              else 
                task.start = Date.today
              end

              tasks.push task if params[:u].blank? || task.user.id == params[:u].to_i
            end
            tasks
          end
          @tasks = @root.full_set

          @total_calendar_days = @tasks.collect(&:end).max - Date.today 

          Rails.cache.fetch("run_sim_#{@root.cache_key}#{Date.today}") do 
            run_simulation
          end 

        end
    end
    # end of class
end


