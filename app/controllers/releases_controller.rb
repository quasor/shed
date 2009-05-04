class ReleasesController < ApplicationController
  # GET /releases
  # GET /releases.xml
  before_filter :login_required
  before_filter :authorized
  def index
    @releases = Release.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @releases }
    end
  end

  # GET /releases/1
  # GET /releases/1.xml
  def show
    redirect_to releases_path
  end

  # GET /releases/new
  # GET /releases/new.xml
  def new
    @release = Release.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @release }
    end
  end

  # GET /releases/1/edit
  def edit
    @task = Release.find(params[:id])
  end

  # POST /releases
  # POST /releases.xml
  def create
    Task.create(:title => 'ECT') if Task.root.nil?
    @release = Release.new(params[:release])
    
    respond_to do |format|
      if @release.save      
        @release.move_to_child_of(Task.root)

	      Task.roots.each do |t|
	        t.updated_at = Time.now
	        t.save
	      end

        flash[:notice] = 'Release was successfully created.'
        format.html { redirect_to(root_path) }
        format.xml  { render :xml => @release, :status => :created, :location => @release }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @release.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /releases/1
  # PUT /releases/1.xml
  def update    
    @release = Release.find(params[:id])

    respond_to do |format|
      if @release.update_attributes(params[:release])
        flash[:notice] = 'Release was successfully updated.'
        format.html { redirect_to(@release) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @release.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /releases/1
  # DELETE /releases/1.xml
  def destroy
    @release = Releases.find(params[:id])
    @release.destroy

    respond_to do |format|
      format.html { redirect_to(releases_url) }
      format.xml  { head :ok }
    end
  end
end
