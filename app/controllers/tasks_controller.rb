class TasksController < ApplicationController

  # GET /tasks
  # GET /tasks.xml
  before_filter :supports_iphone, :only => [:index]
  before_filter :login_required, :except => [:redo]
  def index
    @day_in_pixels = 16
    # init filters
    session[:filter] ||= {}
    session[:filter][:tasks] ||= 1
    session[:filter][:user] ||= current_user.id
    session[:filter][:project] ||= 0
    session[:filter][:tasks] = params[:filter_tasks].to_i unless params[:filter_tasks].blank?
    session[:filter][:user] = params[:filter_user].to_i unless params[:filter_user].blank?
    session[:filter][:project] = params[:filter_project].to_i unless params[:filter_project].blank?
    @taskz = rebuild_schedule(params[:force] == "true", true) 
    #@taskz = Task.root.descendants
    #if session[:filter][:tasks] == 1
    #  @tasks = @taskz.collect {|task| task unless task.completed?}
    #else
    #  @tasks = @taskz
    #end
    @tasks = @taskz.collect do |task|
      skip = false
      if task.type.nil?
        if session[:filter][:tasks] == 1 && task.completed? 
          skip = true
        end  
        if session[:filter][:user] != 0 && session[:filter][:user] != task.user_id
          skip = true
        end  
        if session[:filter][:project] != 0 && session[:filter][:project] != task.parent_id
          skip = true
        end  
      end
      if skip
        logger.info 'skipping task...'
      end
      task unless skip
    end
    @tasks.compact!

   @tasks ||= []

   @holidays = Rails.cache.fetch("Holiday.all.holiday") do
     Holiday.find(:all, :select => :holiday).collect(&:holiday)
   end
    
   @simulation = Simulation.last
	@today = Date.today
    
    if Release.count == 0
      flash[:warning] = 'Your schedule is empty'
    else
      # flash[:notice] = "Last updated at #{Task.root.updated_at.to_s()}"
    end
    respond_to do |format|
      format.html # index.html.erb
      format.iphone 
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
    @tasks = Task.find @order
    
    unless @tasks.empty? || @tasks.size < 2
      logger.info @order.collect { |i| Task.find(i).title }.join ','
      #@order.delete_if { |i| !Task.find(i).type.nil? }
      @order.each_with_index do |o,i|
        task = Task.find o
        unless i == 0
          puts "moving #{@order[i]} to right of #{@order[i-1]}"
          preceeding_task = Task.find @order[i-1]
          task.move_to_right_of preceeding_task if task.type.nil? && (admin? || current_user.id == task.user_id)
        else 
          puts "move to top"
          #task.move_to_top if task.type.nil?
        end
      end

      Task.roots.each do |t|
        t.updated_at = Time.now
        t.save
      end
    
      rebuild_schedule
    end
        
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
		@task.title = 'New Task' if request.xhr?
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
			format.js	{ 
				render :update do |page|
					page.replace_html "edit_task_#{params[:parent_id]}", :partial => "new"
					page["task_title"].focus
					page["task_title"].select
				end				
				}

    end
  end

  # GET /tasks/1/edit
  def edit
    if admin?
      @task = Task.find(params[:id]) 
    else
      @task = Task.find(params[:id]) 
    end
    respond_to do |format|
      format.html { render :layout => false }
      format.js  { 
				render :update do |page|
					page.replace_html "edit_task_#{params[:id]}", :partial => "edit"
					page["task_title"].focus
					page["task_title"].select						
				end
			}
    end
  end

  # POST /tasks
  # POST /tasks.xml
  def create
    @task = Task.new(params[:task])
    
#    unless params[:task].nil? || params[:task][:low].blank?
#      low,high = params[:task][:low].split "-" 
#      @task.low = string_to_days(low)
#      @task.high = string_to_days(high) unless high.nil?
#      @task.high = string_to_days(params[:task][:high]) unless params[:task][:high].nil?
#    end
    
    respond_to do |format|
      if @task.save
        unless (params[:parent_id].blank?)
          @task.move_to_child_of(Task.find(params[:parent_id]))
        end
        Rails.cache.increment "dirty"

				t = Task.root
	      t.updated_at = Time.now
	      t.save

        flash[:notice] = 'Task was successfully created.'
        format.html { redirect_to current_user }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
				format.js { 
					render :update do |page|
						page.remove "new_task"
						page.insert_html :bottom, "taskList#{params[:parent_id]}", :partial => @task
						#page["task_#{@task.id}"].scrollTo
						page.visual_effect :highlight, "task_#{@task.id}"						
						# insert another:
						@task = Task.new
						@task.title = 'Another New Task (ESC to close)'
						@task.user = current_user
						page.replace_html "edit_task_#{params[:parent_id]}", :partial => "new"
						page["task_title"].focus
						page["task_title"].select						
						
					end
					}
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
      if @task.update_attributes(params[:task] || params[:project])
        Rails.cache.increment "dirty"
        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to current_user }
        format.xml  { head :ok }
				format.js { 
					render :update do |page|
						page.replace "task_#{@task.id}", :partial => @task
						page.visual_effect :highlight, "task_#{@task.id}"
					end
					}
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
        Rails.cache.increment "dirty"
        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to(user_path(current_user, :timer => true)) }
        format.xml  { head :ok }
				format.js { 
					render :update do |page|
						page.replace "task_#{@task.id}", :partial => @task
						page.visual_effect :highlight, "task_#{@task.id}"
					end
					}
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end

    
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  def destroy
    @task = (admin? ? Task : current_user.tasks).find(params[:id])
		@task_id = @task.id
    @task.destroy
    Rails.cache.increment "dirty"

    respond_to do |format|
      format.html { redirect_to(current_user) }
      format.xml  { head :ok }
			format.js {
				render :update do |page|
					page.remove "task_#{@task_id}"
				end
			}
    end
  end
    
  def bulk
    Rails.cache.increment "dirty"
    @text = params[:tasks]
    @rows = @text.chomp.strip.split("\n").collect {|t| t.split(',') }
    @tasks = []
    
    @rows.collect do |r|
      if r.size > 3
        @low = r[3].strip
        @project = Task.find params[:project_id]
        unless @project.nil? || @low.blank?
          @user = User.find_by_name(r[0].strip) || User.find_by_login(r[0].strip)
          @user_id = @user.id unless @user.nil?
          e = r[3]
          e = r[3] +  ' - ' + r[4] unless r[4].nil?
          @task = Task.new(:title => r[2].strip, :estimate => e, :user_id => @user_id)
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

  def redo
    @dirty = Rails.cache.fetch("dirty") { 1 }
    @rebuilt = false
		@root = Task.root
		@root.reload
    Rails.cache.fetch("schedule_is_#{@root.cache_key}#{Date.today}", :expires_in => 1.hour) do
       rebuild_schedule(true) 
       @rebuilt = true       
    end
    Rails.cache.fetch("run_sim_#{Task.root.cache_key}") do 
      run_simulation
      @rebuilt = true       
    end 
    render :text => @rebuilt ? " #{Time.now} - Rebuild Complete" : " #{Time.now} - Using Cached Copy"
  end

  def run_simulation
    @simulation = Simulation.create
    logger.warn 'running simulation...'
    durations = []
    #Projection.destroy_all
    @project_date_collection = {}
    @project_user_date_collection = {}
    user_ids = []
    @sim_count = 100
    @task_projections = {}
    @sim_count.times do |i|
      # walk the schedule once
      user_end_dates = {}
      projections={}
      tasks = Task.root.descendants
      tasks.each do |task|
        unless task.user.nil? || task.completed? 
          user_end_dates[task.user.id] ||= Date.today.work_day(0)
          task.start = user_end_dates[task.user.id].work_day(0)
          task_end = user_end_dates[task.user.id] = user_end_dates[task.user.id].work_day(task.monte_estimate)
          projections[task.id] = Projection.new(:start => task.start, :end => task_end, :simulation_id => @simulation.id) if task.type.nil?
          @task_projections[task.id] ||= []
          @task_projections[task.id].push Projection.new(:task_id => task.id, :start => task.start, :end => task_end == task.start ? (task_end + 1) : task_end, :simulation_id => @simulation.id) if task.type.nil?
        else 
          task.start = Date.today
        end
      end
      logger.warn "\n\n\n---------\n#{user_end_dates.inspect}"
      # use the estimates from the simulation to determine the end date of the project
      Project.all.each do |project|
        #project.projections.destroy_all

        # find the end date of each user
        user_ids = project.children.collect {|task| task.user_id }.uniq

        @project_user_date_collection[project.id] ||= {}
        @project_date_collection[project.id] ||= []
        # init 
        user_ids.each {|user_id| @project_user_date_collection[project.id][user_id] ||= [] }
        # find the max end (last task) for this project
        max_end_date = project.children.collect { |c| projections[c.id] }.flatten.compact.collect(&:end).max
        @project_date_collection[project.id].push max_end_date

        user_ids.each do |user_id|
          max_end_date = project.children.collect { |c| projections[c.id] if c.user_id == user_id }.flatten.compact.collect(&:end).max
          @project_user_date_collection[project.id][user_id].push max_end_date
        end
      end
      
      durations.push(user_end_dates.values.max - Date.today)

    end

    @project_date_collection.each_pair do |k,v|
      v.compact!
      v.sort! 
      Projection.create(:task_id => k, :start => v[v.size*0.10], :end => v[v.size*0.95], :simulation_id => @simulation.id)
    end
    
    @project_user_date_collection.each do |pid,hash|
      hash.each_pair do |k,v|
        v.compact!
        v.sort! 
        Projection.create(:task_id => pid, :user_id => k, :start => v[v.size*0.10], :end => v[v.size*0.95], :simulation_id => @simulation.id)
      end
    end

    Release.all.each do |release|
      projections = release.children.collect {|project| project.projections.rollup.last }
      unless projections.empty?
        s = projections.collect(&:start).compact.max
        e = projections.collect(&:end).compact.max
        Projection.create(:task_id => release.id, :start => s, :end => e, :simulation_id => @simulation.id) unless s.nil? || e.nil?
      end
    end
    @task_projections.each_pair do |task_id,projections|
#        projections.each { |p| p.save! }
      task = Task.find(task_id)
      mid = projections.size * 0.5
      std_dev1 = projections.size * 0.34
      projections = projections.sort_by {|r| r.end }
      starts = projections.collect(&:start).sort
      ends = projections.collect(&:end).sort
      unless projections.empty? || !task.type.nil? || task.completed?
        Projection.create(:task_id => task.id, :start => starts[mid], :end => ends[mid] == starts[mid] ? (ends[mid] + 1) : ends[mid], :confidence => 1) # mean
        Projection.create(:task_id => task.id, :start => starts[mid-std_dev1], :end => ends[mid+std_dev1] == starts[mid-std_dev1] ? (ends[mid+std_dev1] + 1) : projections[mid+std_dev1].end, :confidence => 67) # mean
      end
    end
    
#    Task.active(true).each do |task|
#      prjs = task.projections.simulation(@simulation.id).sort_by{|p| p.start}
#      mid = prjs.size * 0.5
#      std_dev1 = prjs.size * 0.34
#      unless prjs.empty? || !task.type.nil? || task.completed?
#        Projection.create(:task_id => task.id, :start => prjs[mid].start, :end => prjs[mid].end, :confidence => 1) # mean
#        Projection.create(:task_id => task.id, :start => prjs[mid-std_dev1].start, :end => prjs[mid+std_dev1].end, :confidence => 67) # mean
#      end
#    end
    
    logger.info '---------------------- Completed simulation ---------------------- '
    
  end
    private
    
    def rebuild_schedule(force = false, fromUI = false)
        @root = Task.root
        # @root = Task.find current_user.team_id unless current_user.nil? # replace this later with a local root
        @total_calendar_days = 0
        unless @root.nil?
        if force
          @root.updated_at = Time.now
          @root.save!
        end
        @dirty = Rails.cache.fetch("dirty") { 1 }
        Release.all
        Project.all
        t = Rails.cache.fetch("schedule_#{@root.cache_key}-#{@dirty}", :expires_in => 1.hour ) do 
            user_end_dates = {}
            tasks = []
            @tasks_raw = Task.root.descendants
            # Compute start times for each task
            @tasks_raw.each do |task|
              unless task.user.nil? || task.completed?
                # compute the schedule
                user_end_dates[task.user.id] ||= Date.today.work_day(0)
                task.start = user_end_dates[task.user.id].work_day(0)
                task.end = user_end_dates[task.user.id] = user_end_dates[task.user.id].work_day(task.estimate_days)
									
								task.start = task.start.to_datetime + task.start.day_fraction
								task.end = task.end.to_datetime + task.end.day_fraction

                task.save! #unless fromUI
              else 
                task.start = Date.today.to_datetime
              end
            end
          end
          
          # done with the rebuild...
          
        end
        alltasks = Task.root.descendants
        unless alltasks.empty?
          end_dates = alltasks.collect(&:end) 
          unless end_dates.compact.empty?
            @total_calendar_days = [end_dates.compact.max.to_date - Date.today,14].max + 7	
          end
        end
        #@tasks_raw
				t
    end
    # end of class
end


