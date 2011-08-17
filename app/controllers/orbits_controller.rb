# Knorbit - knowledge management software
# Copyright (C) 2011  David Bayo, Galo Gimenez
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

# The OrbitsController is like SpacesController but uses the Orbit name instead of the UUID, so only works
# within the context of a single user
class OrbitsController < ApplicationController
  before_filter :authenticate_user!
   
  # GET /orbits
  # GET /orbits.xml
  # GET /orbits.json
  def index
    @jobs = current_user.jobs
    
    #@spaces = Space.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @jobs }
      format.json { render :json => @jobs.to_json }
    end
  end
  
  
  # GET /orbits/orbit_name
  def show
	  @space = Space.where(:name => params[:id])[0]
    @job = Job.where(:name => params[:id])[0]
     # @comments = @space.comments.order('updated_at DESC') 
  
    respond_to do |format|
      format.html {redirect_to(space_path(@space.wiki_name))}
      format.xml  { render :xml => @space }
      format.json  { render :json => @space.to_json }
    end
  end
end
