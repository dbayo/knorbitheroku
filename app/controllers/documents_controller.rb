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

#require "tools/document_diff/document_diff.rb"
require "tools/html_differ/html_differ.rb"

class DocumentsController < ApplicationController
  OWNER_COLOR = "black"
  COLORS = ["darkblue", "red", "sddlebrown", "green", "purple"]
  COLOR_MODEB = "gray"
  
  before_filter :authenticate_user!
    	
    
  # GET /document
  # GET /document.xml
  # GET /document.json
  def index
    @space = Space.where(:wiki_name => params[:space_id])[0]
    @documents = @space.documents.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @documents }
      format.json { render :json => @documents.to_json }
    end
  end
    		
  # GET /document/new
  # GET /document/new.xml
  def new
    @space = Space.where(:wiki_name => params[:space_id])[0]
    @document = @space.documents.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @document }
      format.json { render :json => @document.to_json }
    end
  end
  
  def create
      @space = Space.find(params[:space_id])
      @document = @space.documents.create(params[:document])
      
      respond_to do |format|
        if @document.save
          #format.html { redirect_to(@document, :notice => 'Document was successfully created.') }
          format.html {redirect_to space_path(@space.wiki_name)}
          format.xml  { render :xml => @document, :status => :created, :location => @document }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
        end
      end
      #redirect_to space_path(@space)
  end
  
  def show
  	@space = Space.where(:wiki_name => params[:space_id])[0]
  	@job = Job.where(:wikispace => params[:space_id])[0]
    @document = Document.find(params[:id])  
    
    puts "\n\n\n\n SHOW"
    puts @document.content

    @users_in_doc = []
    @users_in_doc << {:id => "user#{@job.user.id}", 
                      :name => @job.user.name,
                      :color => OWNER_COLOR, 
                      :colorA => OWNER_COLOR, 
                      :colorB => OWNER_COLOR, 
                      :colorC => OWNER_COLOR,
                      :box => true}
    
    @job.contributed.each_with_index do |contrib,i|
      if(i < COLORS.size)
        @users_in_doc << {:id => "user#{contrib.user.id}", 
                          :name => contrib.user.name,
                          :color => COLORS[i], 
                          :colorA => OWNER_COLOR, 
                          :colorB => COLOR_MODEB, 
                          :colorC => COLORS[i],
                          :box => true}    
      else
        @users_in_doc << {:id => "user#{contrib.user.id}", 
                          :name => contrib.user.name,
                          :color => COLOR_MODEB, 
                          :colorA => OWNER_COLOR, 
                          :colorB => COLOR_MODEB, 
                          :colorC => COLOR_MODEB,
                          :box => false}    
      end
    end

    @comments = @space.comments.order('updated_at DESC')
    
    #Update the last visit in this job
    @activity = Activity.find(:first, :conditions => ['user_id = ? and job_id = ? and code = ?', current_user.id, @job.id, 3])
    if @activity.nil?
        current_user.activities.create(:job_id => @job.id, :code => 3)
    else
        @activity.update_attributes(:message => "Last visit : "+Time.now.to_s)
    end
    
      respond_to do |format|
        format.html { render :notice => notice } # show.html.erb
        format.xml  { render :xml => @document }
      end
  end
  
  # PUT /documents/1
  # PUT /documents/1.xml
  def update
    @document = Document.find(params[:id])
    @oldname = @document.name
    @oldcontent = @document.content
    @space = @document.space
    @edited_content = params[:document][:content]
    @job = Job.where(:wikispace => @space.wiki_name)[0]
    @comments = @space.comments.order('updated_at DESC') 
  
    #Check there isn't a newer version in the DB
    #dd = DateTime.parse(t.to_s)
    #tt = Time.parse(d.to_s)
    
    d = @document.updated_at.to_datetime.to_i - params[:document][:updated_at].to_datetime.to_i 
    puts "Document in DB was updated at #{@document.updated_at.to_datetime.to_i}"
    puts "My copy was updated at #{params[:document][:updated_at].to_datetime.to_i}"
    puts "The diference: #{d}"
    puts "Editedt content:" + @edited_content
    
    if ( d != 0)
      puts "Conflict"
      @conflict = true
      @diff = Diffy::Diff.new(@edited_content, @oldcontent).to_s(:html)
    else
      @conflict = false
      
      #Get the diff and set to the user
      diffed = HtmlDiffer.diff(@oldcontent, @edited_content.strip, "#{current_user.id}")
      
      #save to a file for debugging in case of finding errors
#      File.open("diffdebugtest.log", "a+") do |f|
#        f.puts("old = %Q{#{@oldcontent}}")
#        f.puts("new = %Q{#{@edited_content.strip}}")
#        f.puts("result = %Q{#{diffed}}")
#      end
      
      params[:document][:content] = diffed
      
      @success =  @document.update_attributes(params[:document])
      @activity = Activity.find(:all, :conditions => ['user_id = ? and job_id = ? and code = ?', current_user.id, @job.id, 1])
      current_user.activities.create(:job_id => @job.id, :code => 1) unless !@activity[@activity.count-1].nil? && @activity[@activity.count-1].created_at.to_date == Date.today
      current_user.activities.create(:job_id => @job.id, :code => 2)
    end 
    
    #If there is no conflict save the document and update the verions
    if @success
    	params[:oldcont] = @oldcontent
    	params[:newcont] = @document.content
    	if @oldcontent != @document.content
	      	version_hash = UUIDTools::UUID.timestamp_create.to_s
	      	@user = current_user
	      	@version = @document.versions.create(:content =>@document.content,:version => version_hash, :user_id=> current_user.id)
	      	@version.save
      	end
    end
    
    respond_to do |format|
      if @success 
        format.html { redirect_to "/spaces/"+@space.wiki_name+"/documents/"+@document.id.to_s, :notice => "Saved"  }
        format.xml  { head :ok }
      elsif @conflict 
        #format.html { redirect_to "/spaces/"+@space.wiki_name+"/documents/"+@document.id.to_s, :notice => "Conflict"  }
        format.html { render :action => :show , :notice => "Conflict"} 
        format.xml  { head :ok }
      else
        format.html { render :action => :show , :notice => "Error"}
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  
  # GET /documents/1/edit
   def edit
     @document = Document.find(params[:id])
     @space = @document.space
   end
  
  def save
  	 @document = Document.find(params[:id])
  	 @document.update_attributes(params[:document])
  	 
  	 respond_to do |format|
        format.html { redirect_to space_path(@space.wiki_name)}
        format.xml  { head :ok }
      end
  end
  
  def savecommentajax
      @document = Document.find(params[:id])
      @space = @document.space
      if !params[:comment].empty?
          @comment = @space.comments.create(:comment => params[:comment], :user_id => current_user.id)
      end
      
      @comments = @space.comments.order('updated_at DESC')
      @out = ''
      
      @out.concat('<table>')
      @comments[0,5].each do |comment|
        @out.concat('<tr>')
        @out.concat('<td rowspan="2" style="padding-bottom: 20px;">')
        @out.concat('<img class="gravatar" src="http://gravatar.com/avatar/')
        @out.concat(Digest::MD5::hexdigest(comment.user.email))
        @out.concat('?size=30"> ')
        @out.concat('</td><td>')
        @out.concat('<b class="user')
        @out.concat(comment.user.id.to_s)
        @out.concat('">')
        @out.concat(comment.user.name)
        @out.concat('</b> - ')
        @out.concat(comment.comment)
        @out.concat('</td></tr><tr><td style="padding-bottom: 20px;"><font size="-1" color="#6f6f6f">')
        @out.concat(comment.created_at.to_s)
        @out.concat('</font></td></tr> ')
        @out.concat('')
      end
      @out.concat('</table>')
      
      if @comments.length > 5
          @out.concat('<div id="comments" style="display:none;">')
          @out.concat('<table>')
          @comments[5,@comments.length].each do |comment|
              @out.concat('<tr>')
              @out.concat('<td rowspan="2" style="padding-bottom: 20px;">')
              @out.concat('<img class="gravatar" src="http://gravatar.com/avatar/')
              @out.concat(Digest::MD5::hexdigest(comment.user.email))
              @out.concat('?size=30"> ')
              @out.concat('</td><td>')
              @out.concat('<b class="user')
              @out.concat(comment.user.id.to_s)
              @out.concat('">')
              @out.concat(comment.user.name)
              @out.concat('</b> - ')
              @out.concat(comment.comment)
              @out.concat('</td></tr><tr><td style="padding-bottom: 20px;"><font size="-1" color="#6f6f6f">')
              @out.concat(comment.created_at.to_s)
              @out.concat('</font></td></tr> ')
              @out.concat('')
          end
          @out.concat('</table>')
          @out.concat('</div>')
          @out.concat('<a id="textcomments" onclick="showcomments()" style="color:green; cursor:pointer;">More comments...</a>')
      end
     
      render :text => @out
  end
end
