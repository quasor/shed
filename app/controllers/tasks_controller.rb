class TasksController < ApplicationController
  # GET /tasks
  # GET /tasks.xml
  before_filter :login_required
  def index
    @day_in_pixels = 32
    @tasks = []
    
    unless params[:filter].blank?
      unless params[:filter][:user_id].blank?
        session[:user_id] = params[:filter][:user_id]
      end
    end
   
   @tasks = rebuild_schedule(params[:force] == "true") 
   
   unless params[:u].blank?
     user_id = params[:u].to_i
#     @tasks.delete_if {|t| t.user_id != user_id && t.type.nil? }   
   end

   unless params[:p].blank?
     project_id = params[:p].to_i
#     @tasks.delete_if {|t| t.parent_id != project_id && t.type.nil? }   
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
    @tasks = Task.find @order
    
    unless @tasks.empty? || @tasks.size < 2
      logger.info @order.collect { |i| Task.find(i).title }.join ','
      @order.delete_if { |i| !Task.find(i).type.nil? }
      @order.each_with_index do |o,i|
        task = Task.find o
        unless i == 0
          puts "moving #{@order[i]} to right of #{@order[i-1]}"
          preceeding_task = Task.find @order[i-1]
          task.move_to_right_of preceeding_task if task.type.nil?
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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    if admin?
      @task = Task.find(params[:id]) 
    else
      @task = Task.find(params[:id]) 
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
        Rails.cache.increment "dirty"
        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to(tasks_url(:p => @task.parent_id )) }
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
        Rails.cache.increment "dirty"
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
    @task = (admin? ? Task : current_user.tasks).find(params[:id])
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
          @task = Task.new(:title => r[2].strip, :estimate => r[3] +  ' - ' + r[4], :user_id => @user_id)
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


  def run_simulation
    logger.warn 'running simulation...'
    durations = []
    #Projection.destroy_all
    @project_date_collection = {}
    @project_user_date_collection = {}
    user_ids = []
    100.times do |i|
      # walk the schedule once
      user_end_dates = {}
      projections={}
      tasks = Task.root.all_children
      tasks.each do |task|
        unless task.user.nil? || task.completed? 
          user_end_dates[task.user.id] ||= Date.today.work_day(0)
          task.start = user_end_dates[task.user.id].work_day(0)
          task_end = user_end_dates[task.user.id] = user_end_dates[task.user.id].work_day(task.monte_estimate)
          projections[task.id] = Projection.new(:start => task.start, :end => task_end) if task.type.nil?
        else 
          task.start = Date.today
        end
      end
      
      # use the estimates from the simulation to determine the end date of the project
      Project.all.each do |project|
        #project.projections.destroy_all

        # find the end date of each user
        user_ids = project.children.collect {|task| task.user_id }.uniq

        @project_user_date_collection[project.id] ||= {}
        @project_date_collection[project.id] ||= []

        user_ids.each {|user_id| @project_user_date_collection[project.id][user_id] ||= [] }

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
      Projection.create(:task_id => k, :start => v[10], :end => v[95])
    end
    
    @project_user_date_collection.each do |pid,hash|
      hash.each_pair do |k,v|
        v.compact!
        v.sort! 
        Projection.create(:task_id => pid, :user_id => k, :start => v[10], :end => v[95])
      end
    end

    @user_ids = user_ids

    #render :inline => "<%= debug @project_date_collection%><%= debug @project_user_date_collection[112][1] %><%= debug @user_ids%>"
    
  end
    private
    
    def rebuild_schedule(force = false)
        @root = Task.root # replace this later with a local root

        @total_calendar_days = 0
        @dirty = Rails.cache.fetch("dirty") { 1 }
        unless @root.nil?
          suffix = force ? rand(20).to_s : ""
          t = Rails.cache.fetch("tasks__#{@root.cache_key}-#{Task.count}-#{Task.last.id}#{@dirty}"+suffix) do #
            user_end_dates = {}
            tasks = []
            @tasks_raw = Task.root.all_children
            # Compute start times for each task
            @tasks_raw.each do |task|
              unless task.user.nil? || task.completed? 
                user_end_dates[task.user.id] ||= Date.today.work_day(0)
                task.start = user_end_dates[task.user.id].work_day(0)
                task.end = user_end_dates[task.user.id] = user_end_dates[task.user.id].work_day(task.estimate_days)
                task.save
              else 
                task.start = Date.today
              end

              tasks.push task if params[:u].blank? || task.user.id == params[:u].to_i
            end
          end
          
          # done with the rebuild...
          
          alltasks = Task.root.all_children
          unless alltasks.empty?
            end_dates = alltasks.collect(&:end) 
            unless end_dates.compact.empty?
              @total_calendar_days = [end_dates.compact.max - Date.today,14].max + 14
            end
            Rails.cache.fetch("run_sim_#{Date.today}#{@dirty}") do 
              run_simulation
            end 
          end
          t
        end
    end
    # end of class
end


