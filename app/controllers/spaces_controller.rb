# Knorbit - knowledge management software
# Copyright (C) 2011  Davi Bayo, Galo Gimenez
#
#MIT License
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

class SpacesController < ApplicationController
  before_filter :authenticate_user!
    	
  # GET /spaces
  # GET /spaces.xml
  # GET /spaces.json
  def index
    @spaces = Space.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @spaces }
      format.json { render :json => @spaces.to_json }
    end
  end

  # GET /spaces/1
  # GET /spaces/1.xml
  # GET /spaces/1.json
  def show
	  @space = Space.where(:wiki_name => params[:id])[0]
    @job = Job.where(:wikispace => params[:id])[0]
    @comments = @space.comments.order('updated_at DESC') 
	
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @space }
      format.json { render :json => @space.to_json }
    end
  end

  # GET /spaces/new
  # GET /spaces/new.xml
  def new
    @space = Space.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @space }
    end
  end

  # GET /spaces/1/edit
  def edit
    @space = Space.find(params[:id])
  end

  # POST /spaces
  # POST /spaces.xml
  def create
    @space = Space.new(params[:space])

    respond_to do |format|
      if @space.save
        format.html { redirect_to(@space, :notice => 'Space was successfully created') }
        format.xml  { render :xml => @space, :status => :created, :location => @space }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @space.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /spaces/1
  # PUT /spaces/1.xml
  def update
    @space = Space.find(params[:id])
    @comment = @space.comments.create(:comment => params[:comment], :user_id => current_user.id)

    respond_to do |format|
      if @space.update_attributes(params[:space])
        format.html { redirect_to(space_path(@space.wiki_name), :notice => 'Space was successfully updated') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @space.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /spaces/1
  # DELETE /spaces/1.xml
  def destroy
    @space = Space.find(params[:id])
    @space.destroy

    respond_to do |format|
      format.html { redirect_to(spaces_url) }
      format.xml  { head :ok }
    end
  end
  
  def version
    @space = Space.where(:wiki_name => params[:space_id])[0]
    @job = Job.where(:wikispace => params[:space_id])[0]
    @comments = @space.comments.order('updated_at DESC') 
    @spaceversion = Spaceversion.find(params[:id])
    
    respond_to do |format|
      format.html
      format.xml  { head :ok }
    end
  end
  
  def exportPDF
    @space = Space.where(:wiki_name => params[:space_id])[0]
    @job = Job.where(:wikispace => params[:space_id])[0]
    @documents = @space.documents
     
    respond_to do |format|
      format.html
      format.pdf do
             render :pdf => "file_name"
      end
    end
  end
end
