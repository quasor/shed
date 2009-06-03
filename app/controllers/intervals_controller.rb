class IntervalsController < ApplicationController
  # GET /intervals
  # GET /intervals.xml
  def index
    unless params[:user_id].blank?
      @user = User.find params[:user_id] 
    else
      @user = current_user
    end
    @intervals = @user.intervals.reverse

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @intervals }
    end
  end

  # GET /intervals/1
  # GET /intervals/1.xml
  def show
    @interval = Interval.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @interval }
    end
  end

  # GET /intervals/new
  # GET /intervals/new.xml
  def new
    @interval = Interval.new
		@task = Task.find params[:task_id]
    @interval.task = @task
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @interval }
    end
  #rescue
  #  redirect_to intervals_path
  end

  # GET /intervals/1/edit
  def edit
    @interval = Interval.find(params[:id])
  end

  # POST /intervals
  # POST /intervals.xml
  def create
    @interval = Interval.new(params[:interval])
		unless params[:interval][:hours].blank?
			@task = Task.find params[:interval][:task_id]
			@task.intervals(true).find(:all, :conditions => {:created_at => Date.today..Date.today+1}).collect(&:destroy)
			@interval.end = DateTime.now
			hours = (parse_as_days(params[:interval][:hours]).to_f * WORKING_HOURS_PER_DAY)
			@interval.start = DateTime.now - hours.hours
		end
    @interval.user = current_user
    respond_to do |format|
      if @interval.save!
        @interval.task.update_attributes(params[:task])
        flash[:notice] = 'Hours were successfully logged.'
        format.html { redirect_to(root_path) }
        format.xml  { render :xml => @interval, :status => :created, :location => @interval }
				format.js {
					render :update do |page|
						@el = "interval_hours_#{@task.id}"
						page[@el].val("#{@task.time_spent_today}")
						page.visual_effect :highlight, @el						
					end
				}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @interval.errors, :status => :unprocessable_entity }
      end
    end
		#@interval.task.intervals.
  end

  # PUT /intervals/1
  # PUT /intervals/1.xml
  def update
    @interval = Interval.find(params[:id])

    respond_to do |format|
      if @interval.update_attributes(params[:interval])
        flash[:notice] = 'Interval was successfully updated.'
        format.html { redirect_to(intervals_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @interval.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /intervals/1
  # DELETE /intervals/1.xml
  def destroy
    @interval = Interval.find(params[:id])
    @interval.destroy

    respond_to do |format|
      format.html { redirect_to(intervals_url) }
      format.xml  { head :ok }
    end
  end
end
