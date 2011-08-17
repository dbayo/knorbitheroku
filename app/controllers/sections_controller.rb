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

# The SectionsController is like DocumentsController but uses the Orbit name instead of the UUID, so only works
# within the context of a single user

class SectionsController < ApplicationController
  
  
  # GET /sections
  # GET /sections.xml
  # GET /sections.json
  def index
    @space = Space.where(:name => params[:orbit_id])[0]
    @documents = @space.documents.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @documents }
      format.json { render :json => @documents.to_json }
    end
  end
  

  # GET /orbits/orbit_name/sections/section_name
  def show
  	@space = Space.where(:name => params[:orbit_id])[0]
    @document = Document.find(params[:id])  
    
    respond_to do |format|
        format.html {redirect_to("/spaces/"+@space.wiki_name+"/documents/"+@document.id.to_s)}
        format.xml  { render :xml => @document }
        format.json  { render :jsom => @document.to_json }
    end
  end
end
