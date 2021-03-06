class TasksController < ApplicationController

  # GET /tasks
  # GET /tasks.xml
  before_filter :supports_iphone, :only => [:index]
  before_filter :login_required, :except => [:redo]
  def index
    @pixels_per_day =12
    @total_calendar_days = 60
		@today = Date.today
    # init filters
    session[:filter] ||= {}
    session[:filter][:tasks] ||= 0
    session[:filter][:user] ||= current_user.id
    session[:filter][:project] ||= 0
    session[:filter][:tasks] = params[:filter_tasks].to_i unless params[:filter_tasks].blank?
    session[:filter][:user] = params[:filter_user].to_i unless params[:filter_user].blank?
    session[:filter][:project] = params[:filter_project].to_i unless params[:filter_project].blank?
		if session[:filter][:user] != 0
			@user_id = session[:filter][:user]
			
			@project_ids = (Task.find(:all,:conditions => {:user_id => @user_id, :type => nil}).collect(&:parent).collect(&:parent) + Task.find(:all,:conditions => {:user_id => @user_id, :type => nil}).collect(&:parent)).uniq.compact.map(&:id).sort
		end
    @users = User.all
    @releases = Release.all
    @releases_upcoming = Release.upcoming
    @releases_past = @releases - @releases_upcoming
    
    #@tasks = @releases_upcoming.collect { |r| [r] + r.descendants.inorder.find(:all, :conditions =>  "(user_id = 25 OR type != 'NULL')") }.flatten #, :conditions => {:completed => false } 
    @taskz = @releases_upcoming.collect{ |r| r.self_and_descendants.inorder }.flatten 
    #@tasks = [Release.last] + Release.last.descendants.inorder
    #@tasks = Task.root.descendants.find :all, :order => "position", :conditions => {:completed => false }

     @tasks = @taskz.collect do |task|
       skip = false
       if task.type.nil?
         if session[:filter][:user] != 0 && (session[:filter][:user] != task.user_id )
           skip = true
         end  
         if !skip && session[:filter][:project] != 0 && session[:filter][:project] != task.parent_id
           skip = true
         end
         if !skip && session[:filter][:tasks] == 1 && (task.completed? || task.parent.on_hold? || task.parent.parent.completed? || task.parent.completed?)
           skip = true
         end  
   		else
 				#
 				if task.type == "Release" || task.type == "Project"
 					if session[:filter][:user] != 0 && !@project_ids.include?(task.id) 
 	      		skip = true
 	        end  
 	        !skip && if session[:filter][:tasks] == 1 && (task.completed? || (task.type == "Project" && task.parent.completed?))
 	          skip = true
 	        end  

 				end
       end
       #if skip
       #  logger.info 'skipping task...'
       #end
       task unless skip
     end
     @tasks.compact!

    @tasks ||= []
    end_dates = @tasks.collect(&:end) 
    unless end_dates.compact.empty?
      @total_calendar_days = [end_dates.compact.max.to_date - Date.today,14].max + 28	
    end

    if Release.count == 0
      flash[:warning] = 'Your schedule is empty'
    else
      # flash[:notice] = "Last updated at #{Task.root.updated_at.to_s()}"
    end
		colors = ["#E2FEFE", "#F6DAFC", "#FFFEDC", "#D8D9FB"]
		@releases = Release.find(:all, :order => 'due')
		@release_color=[]
		@releases.each_with_index do |r,i|
			@release_color[r.id] = colors[i%colors.size]			
		end

    render :template => "tasks/index"
  end
  
  def list # old index
    @pixels_per_day =12
    # init filters
    session[:filter] ||= {}
    session[:filter][:tasks] ||= 1
    session[:filter][:user] ||= current_user.id
    session[:filter][:project] ||= 0
    session[:filter][:tasks] = params[:filter_tasks].to_i unless params[:filter_tasks].blank?
    session[:filter][:user] = params[:filter_user].to_i unless params[:filter_user].blank?
    session[:filter][:project] = params[:filter_project].to_i unless params[:filter_project].blank?
    @taskz = rebuild_schedule(params[:force] == "true", true) 
    
    # @total_calendar_days = 60
    # @taskz = Task.root.descendants.find :all, :order => "position"
    # if session[:filter][:tasks] == 1
    #   @tasks = @taskz.collect {|task| task unless task.completed?}
    # else
    #   @tasks = @taskz
    # end
				
		if session[:filter][:user] != 0
			@user_id = session[:filter][:user]
			
			@project_ids = (Task.find(:all,:conditions => {:user_id => @user_id, :type => nil}).collect(&:parent).collect(&:parent) + Task.find(:all,:conditions => {:user_id => @user_id, :type => nil}).collect(&:parent)).uniq.compact.map(&:id).sort
		end
    @tasks = @taskz.collect do |task|
      skip = false
      if task.type.nil?
        if session[:filter][:user] != 0 && (session[:filter][:user] != task.user_id )
          skip = true
        end  
        if !skip && session[:filter][:project] != 0 && session[:filter][:project] != task.parent_id
          skip = true
        end
        if !skip && session[:filter][:tasks] == 1 && (task.completed? || task.parent.on_hold? || task.parent.parent.completed? || task.parent.completed?)
          skip = true
        end  
  		else
				#
				if task.type == "Release" || task.type == "Project"
					if session[:filter][:user] != 0 && !@project_ids.include?(task.id) 
	      		skip = true
	        end  
	        !skip && if session[:filter][:tasks] == 1 && (task.completed? || (task.type == "Project" && task.parent.completed?))
	          skip = true
	        end  

				end
      end
      #if skip
      #  logger.info 'skipping task...'
      #end
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
		colors = ["#E2FEFE", "#F6DAFC", "#FFFEDC", "#D8D9FB"]
		@releases = Release.find(:all, :order => 'due')
		@release_color=[]
		@releases.each_with_index do |r,i|
			@release_color[r.id] = colors[i%colors.size]			
		end

    respond_to do |format|
      format.html # index.html.erb
      format.iphone 
      format.xml 
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
    
    @order = params[:task]

    Task.transaction do
			@tasks = Task.find @order
	    @previous_positions = @tasks.collect(&:position).sort
			#logger.info "previous positions:#{@previous_positions.inspect}"
	    unless @tasks.empty? || @tasks.size < 2
	      #logger.info @order.collect { |i| Task.find(i).title }.join ','
	      #@order.delete_if { |i| !Task.find(i).type.nil? }
	      @order.each_with_index do |o,i|
					if false
		        task = Task.find o
		        unless i == 0
		          puts "moving item:#{i} #{@order[i]} to right of #{@order[i-1]}"
		          preceeding_task = Task.find @order[i-1]
		          task.move_to_right_of preceeding_task if task.type.nil? && (admin? || current_user.id == task.user_id)
		        else 
		          puts "move to top"
		          #task.move_to_top if task.type.nil?
		        end
					else
						task = Task.find o
						task.position = @previous_positions[i]
						task.save
					end
	      end

				Task.root.touch	    
	      #rebuild_schedule
	    end
     
		end
    render :update do |page|
      page.replace_html 'flash', :partial => 'refresh'
			page['flash'].show()
    end
  end

  def bulk_new
  end 

  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    @task = Task.new
    @task.user_id = current_user.id
		@task.title = 'New Task' if request.xhr?
		@parent_id = session[:last_new_parent_id] = (params[:parent_id] || session[:last_new_parent_id])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
			format.js	{ 
				render :update do |page|
					#page.replace_html "edit_task_#{params[:parent_id]}", :partial => "new"
					page.replace_html "edit_task", :partial => "new"
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
		@parent_id = @task.parent_id
    respond_to do |format|
      format.html { }
      format.js  { 
				render :update do |page|
					page.replace_html "edit_task_#{params[:id]}", :partial => "edit"
					if params[:edit_estimate].blank?
						page["task_title_#{@task.id}"].focus
						page["task_title_#{@task.id}"].select						
					else
						page["task_estimate_#{@task.id}"].focus
						page["task_estimate_#{@task.id}"].select						
					end
				end
			}
    end
  end

  # POST /tasks
  # POST /tasks.xml
  def create
	 	@new_task_title = 'Another New Task (ESC to close)'
		@parent_id = session[:last_new_parent_id] = (params[:parent_id] || session[:last_new_parent_id])
	  @users = User.all
    @task = Task.new(params[:task])
    
#    unless params[:task].nil? || params[:task][:low].blank?
#      low,high = params[:task][:low].split "-" 
#      @task.low = string_to_days(low)
#      @task.high = string_to_days(high) unless high.nil?
#      @task.high = string_to_days(params[:task][:high]) unless params[:task][:high].nil?
#    end
    
    respond_to do |format|
			@task.setup_the_version
      if @task.title != @new_task_title && @task.save
			  @task.save_the_version
        unless (params[:parent_id].blank?)
          @task.move_to_child_of(Task.find(params[:parent_id]))
        end

				t = Task.root
	      t.updated_at = Time.now
	      t.save

        flash[:notice] = "Task '#{@task.title}' was successfully created."
        format.html { redirect_to current_user }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
				format.js { 
					render :update do |page|
						page.remove "new_task"
						#page.insert_html :bottom, "taskList#{params[:parent_id]}", :partial => @task
						page.insert_html :bottom, "taskList", :partial => @task
						#page.call "$('#task_#{@task.id}').autoscroll"
						page.visual_effect :highlight, "task_#{@task.id}"						
						# insert another:
						@task = Task.new
						@task.title = @new_task_title
						@task.user = current_user
						page.replace_html "edit_task", :partial => "new"
						page["task_title"].focus
						page["task_title"].select						
						page.replace_html :notice, flash[:notice]
						flash.discard
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
    unless (params[:parent_id].blank?)
      @task.move_to_child_of(Task.find(params[:parent_id]))
    end
	  @users = User.all

		@task.setup_the_version

    respond_to do |format|
      if @task.update_attributes(params[:task] || params[:project])
				@task.save_the_version
				Task.root.touch	
					
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

				Task.root.touch	
				
        flash[:notice] = 'Task was successfully updated.'				
        format.html { redirect_to(user_path(current_user, :timer => true)) }
        format.xml  { head :ok }
				format.js { 
					render :update do |page|
						page.replace "task_#{@task.id}", :partial => @task
						page.visual_effect :highlight, "task_#{@task.id}"
						#page.replace_html :taskList, :partial => current_user.tasks(true)
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
    @rebuilt = false
		@root = Task.root
		@root.reload
    Rails.cache.fetch("schedule_is_#{@root.cache_key}#{Date.today}", :expires_in => 1.hour) do
       rebuild_schedule(true) 
       @rebuilt = true       
    end
    Rails.cache.fetch("run_sim_#{@root.cache_key}#{Date.today}") do 
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
    @sim_count = 10
    @task_projections = {}
    @sim_count.times do |i|
      
      logger.warn "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n ==== SIMULATION ##{i} Step 1/2 ====#{Time.now}\n"
      
      
      # walk the schedule once
      user_end_dates = {}
      projections={}
      tasks = Task.root.descendants

			User.all.each do |user|
				@tasks_raw = user.tasks.find :all, :order => "position"
				# Compute start times for each task
				@tasks_raw.each do |task|
					unless task.user.nil? || task.completed? || task.parent.on_hold?
						
						# compute the schedule
						user_end_dates[task.user.id] ||= Date.today.work_day(0)
						task.start = user_end_dates[task.user.id].work_day(0)
						task.end = user_end_dates[task.user.id] = user_end_dates[task.user.id].work_day(task.monte_estimate) # use a monte estimate, instead of actual estimate

						task.start = task.start.to_datetime + task.start.to_datetime.day_fraction
						task.end = task.end.to_datetime + task.end.to_datetime.day_fraction
						
						# ok, now we've computed the schedule, save the projection
	          projections[task.id] = Projection.new(:start => task.start, :end => task.end, :simulation_id => @simulation.id) if task.type.nil?
	          @task_projections[task.id] ||= []
	          @task_projections[task.id].push Projection.new(:task_id => task.id, :start => task.start, :end => task.end == task.start ? (task.end + 1) : task.end, :simulation_id => @simulation.id) if task.type.nil?
					else 
						task.start = Date.today.to_datetime
					end
				end
			end
      logger.warn "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n ==== SIMULATION ##{i} Step 2/2 ====#{Time.now}\n"
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
				task.best_start = starts[mid-std_dev1]
				task.worst_start = starts[mid]
				task.best_end = ends[mid+std_dev1] == starts[mid-std_dev1] ? (ends[mid+std_dev1] + 1) : projections[mid+std_dev1].end
				task.worst_end = ends[mid] == starts[mid] ? (ends[mid] + 1) : ends[mid] 
				task.save!
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
        Release.all
        Project.all
        t = Rails.cache.fetch("schedule_#{@root.cache_key}", :expires_in => 1.hour ) do 
            user_end_dates = {}
            tasks = []
            
						# @tasks_raw = Task.root.descendants
						t = User.all.each do |user|
							@tasks_raw = user.tasks.incomplete #find :all, :order => "position"
							# Compute start times for each task
	            @tasks_raw.each do |task|
	              unless task.user.nil? || task.completed? || task.parent.on_hold?
	                # compute the schedule
	                user_end_dates[task.user.id] ||= Date.today.work_day(0)
	                
	                task.start = user_end_dates[task.user.id].work_day(0)
	                
	                task.start_in_days = user_end_dates[task.user.id].work_day(0) - Date.today.work_day(0)
	                
									task.end_in_days = ( user_end_dates[task.user.id].work_day(task.estimate_days) - Date.today.work_day(0) )
	                task.end = user_end_dates[task.user.id] = user_end_dates[task.user.id].work_day(task.estimate_days)
									
									task.start = task.start.to_datetime + task.start.to_datetime.day_fraction
									task.end = task.end.to_datetime + task.end.to_datetime.day_fraction

	                task.save! #unless fromUI
	              else 
	                task.start = Date.today.to_datetime
	              end
	            end
						end
          # // end of cache  
          end
          
        # done with the rebuild...
        end
        alltasks = Task.root.descendants
        unless alltasks.empty?
          end_dates = alltasks.collect(&:end) 
          unless end_dates.compact.empty?
            @total_calendar_days = [end_dates.compact.max.to_date - Date.today,14].max + 42	
          end
        end
        #@tasks_raw
				#t
				t = []
				Release.find(:all, :order => 'due').each do |r|
					t << r
					r.children.each do |p|
						t << p
						t << (p.children.find :all, :order => :position)
					end
				end
				t.flatten
    end
    # end of class
end


