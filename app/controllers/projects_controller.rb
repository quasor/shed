class ProjectsController < ApplicationController
  # GET /projects
  # GET /projects.xml
  def index
    @projects = Task.root.descendants
		@projects.delete_if {|p| p.type != "Project"}

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @task = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if !params[:parent_id].blank? && @project.save
        
        unless (params[:parent_id].blank?)
          @project.move_to_child_of(Task.find(params[:parent_id]))
        end

	      Task.roots.each do |t|
	        t.updated_at = Time.now
	        t.save
	      end
        
        flash[:notice] = 'Project was successfully created.'
        format.html { redirect_to(root_path) }
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.find(params[:id])
		@neighbor = params[:neighbor][:project_id] unless params[:neighbor][:project_id].blank?
    respond_to do |format|
      if @project.update_attributes(params[:project])
				unless @neighbor.nil?
					@project.move_to_right_of Project.find(@neighbor)
				end
				
				@root = Task.root
				@root.updated_at = Time.now
        @root.save!
        
				flash[:notice] = 'Project was successfully updated.'
        format.html { redirect_to tasks_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = Project.find(params[:id])
    @project.destroy if @project.leaf?

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end
end
