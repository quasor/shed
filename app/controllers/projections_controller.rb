class ProjectionsController < ApplicationController
  # GET /projections
  # GET /projections.xml
  def index
    @projections = Projection.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projections }
    end
  end

  # GET /projections/1
  # GET /projections/1.xml
  def show
    @projection = Projection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @projection }
    end
  end

  # GET /projections/new
  # GET /projections/new.xml
  def new
    @projection = Projection.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @projection }
    end
  end

  # GET /projections/1/edit
  def edit
    @projection = Projection.find(params[:id])
  end

  # POST /projections
  # POST /projections.xml
  def create
    @projection = Projection.new(params[:projection])

    respond_to do |format|
      if @projection.save
        flash[:notice] = 'Projection was successfully created.'
        format.html { redirect_to(@projection) }
        format.xml  { render :xml => @projection, :status => :created, :location => @projection }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @projection.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projections/1
  # PUT /projections/1.xml
  def update
    @projection = Projection.find(params[:id])
    respond_to do |format|
      if @projection.update_attributes(params[:projection])
        flash[:notice] = 'Projection was successfully updated.'
        format.html { redirect_to(@projection) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @projection.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projections/1
  # DELETE /projections/1.xml
  def destroy
    @projection = Projection.find(params[:id])
    @projection.destroy

    respond_to do |format|
      format.html { redirect_to(projections_url) }
      format.xml  { head :ok }
    end
  end
end
