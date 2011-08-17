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

class JobversionsController < ApplicationController
  before_filter :authenticate_user!
   
  def index
    
  end

  def show
    @job = Job.find(params[:id])
    
    @versions = Jobversion.find(:all, :conditions => ['user_id = ? and job_id = ?', current_user.id, @job.id])
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @jobs }
    end
  end
  
  def create
    @job = Job.find(params[:job_id])

    #1.1- get content
    resource = RestClient::Resource.new 'http://localhost:8080/xwiki/rest/wikis/WIKI/spaces/'+@job.name+'/pages/WebHome', :user => 'Admin', :password => 'admin'
    @webhome = resource.get
    
    coder = HTMLEntities.new
    @webhome = coder.decode(@webhome)    
    
    #2
    resource = RestClient::Resource.new 'http://localhost:8080/xwiki/rest/wikis/WIKI/spaces/'+@job.name+'/pages', :user => 'Admin', :password => 'admin'
    XMLObject.new(resource.get).each do |page|
      if page.name != 'WebHome'
        @page = page.name
        
        #2.2.- Get version
        #to change blank spaces of the links by "+"
        @page = @page.gsub(' ','+')
        resource2 = RestClient::Resource.new 'http://localhost:8080/xwiki/rest/wikis/WIKI/spaces/'+@job.name+'/pages/'+@page, :user => 'Admin', :password => 'admin'
        @version = XMLObject.new(resource2.get).version
        
        #2.3.- Modify webhome variable
        @webhome = @webhome.gsub(page.name+']]', page.name+'>>http://localhost:8080/xwiki/bin/viewrev/'+@job.name+'/'+@page+'?rev='+@version+']]')
      end
    end
    
    @minorVersion = XMLObject.new(@webhome).minorVersion
    @newMinorVersion = @minorVersion.to_i + 1
    
    @webhome = @webhome.gsub('<minorVersion>'+@minorVersion+'</minorVersion>','<minorVersion>'+@newMinorVersion.to_s+'</minorVersion>')
    @webhome = @webhome.gsub(/^.*<page/,'<page')
    
    #3.- Update WebHome of the wiki
    resource = RestClient::Resource.new 'http://localhost:8080/xwiki/rest/wikis/WIKI/spaces/'+@job.name+'/pages/WebHome', :user => 'Admin', :password => 'admin'
    response = resource.put  @webhome, :content_type => 'application/xml'
    
    #4.- Save in Jobversion in the BD
    @jobversion = Jobversion.create(params[:jobversions])
    @jobversion.job_id = params[:job_id]
    @jobversion.user_id = current_user.id
    
    #4.1.- Get the last version
    resource = RestClient::Resource.new 'http://localhost:8080/xwiki/rest/wikis/WIKI/spaces/'+@job.name+'/pages/WebHome', :user => 'Admin', :password => 'admin'
    @version = XMLObject.new(resource.get).version
    @jobversion.version_wiki = @version
    
    respond_to do |format|
      if @jobversion.save
        @job = Job.find(params[:job_id])
        format.html { redirect_to(jobversion_path(@job)) }
        format.xml  { render :xml => @jobversion, :status => :created, :location => @jobversion }
      else
        format.html { render :action => "show" }
        format.xml  { render :xml => @jobversion.errors, :status => :unprocessable_entity }
      end
    end
  end
end
