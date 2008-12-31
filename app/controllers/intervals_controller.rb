class IntervalsController < ApplicationController
  # GET /intervals
  # GET /intervals.xml
  def index
    @intervals = current_user.intervals.reverse

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
  end

  # GET /intervals/1/edit
  def edit
    @interval = Interval.find(params[:id])
  end

  # POST /intervals
  # POST /intervals.xml
  def create
    @interval = Interval.new(params[:interval])
    @interval.user = current_user

    respond_to do |format|
      if @interval.save
        @interval.task.update_attributes(params[:task])
        flash[:notice] = 'Hours were successfully logged.'
        format.html { redirect_to(root_path) }
        format.xml  { render :xml => @interval, :status => :created, :location => @interval }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @interval.errors, :status => :unprocessable_entity }
      end
    end
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
