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
class ProfilesController < ApplicationController
  before_filter :authenticate_user!

  # GET /profile/new
  # GET /profile/new.xml
  def new
    @profile = Profile.new   

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @profile }
    end
  end
  
  def create
    # Create a new empty profile and fill the fields
    params[:profile][:language] = params[:fromBox].join(", ") unless params[:fromBox].nil?
    # Delete ',' of the qualifiers
    params[:profile][:qualifier1].gsub!(/,\s*\z/, '')
    params[:profile][:qualifier2].gsub!(/,\s*\z/, '')
    params[:profile][:qualifier3].gsub!(/,\s*\z/, '')
    params[:profile][:qualifier4].gsub!(/,\s*\z/, '')
    params[:profile][:qualifier5].gsub!(/,\s*\z/, '')
    
    @profile = current_user.create_profile(params[:profile])
    @profile.credit = 0
    @profile.account = 'Free account'
    @profile.reputation = 0
    @profile.oftentags = ''
    
    # Skills
    	@keywords = [params[:profile][:keyword1],params[:profile][:keyword2],params[:profile][:keyword3],params[:profile][:keyword4],params[:profile][:keyword5]] 
	  
       	# For each tag name, check if exist in DB. If exist, increment the frecuency. Else create a new row in the DB
  		@keywords.each do |type|
  			if !type.empty?
	    		@tag = Tag.find(:first, :conditions => ['name = ?', type.strip() ])
	    		if !@tag.nil?
	      			@tag.update_attributes(:frequency => @tag.frequency + 1)
	    		else
	    			@tag = Tag.new
		      		@tag.name = type.strip()
		      		@tag.frequency = 1
		      		@tag.save
	    		end
	    	end     
  		end
	  		
  		@qualifiers = [params[:profile][:qualifier1],params[:profile][:qualifier2],params[:profile][:qualifier3],params[:profile][:qualifier4],params[:profile][:qualifier5]]
	  		
  		$i=0
  		@qualifiers.each do |qualifier|
	  		qualifier.split(",").each do |type|
		        @tag = Tag.find(:first, :conditions => ['name = ?', type.strip()])
		        if !@tag.nil?
		          @tag.update_attributes(:frequency => @tag.frequency + 1 )
				else
	    			@tag = Tag.new
		      		@tag.name = type.strip()
		      		@tag.frequency = 1
		      		@tag.save		       
				end
		    end		     
		    $i = $i + 1
		end
  	#END - Skills
    
    @success = @profile.save
    
    respond_to do |format|
       if @success
         format.html { redirect_to(@profile, :notice => 'Profile was successfully created.') }
         format.xml  { render :xml => @profile, :status => :created, :location => @profile }
       else
         format.html { render :action => "new" }
         format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
       end
     end
  end
  
  def edit 
    @profile = Profile.find(params[:id])
   
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @job }
    end      
  end
  
  def update
  	# Delete ',' of the qualifiers
    params[:profile][:qualifier1].gsub!(/,\s*\z/, '')
    params[:profile][:qualifier2].gsub!(/,\s*\z/, '')
    params[:profile][:qualifier3].gsub!(/,\s*\z/, '')
    params[:profile][:qualifier4].gsub!(/,\s*\z/, '')
    params[:profile][:qualifier5].gsub!(/,\s*\z/, '')
  	
    @profile = current_user.profile
    @success = @profile.update_attributes(params[:profile])
    
    # Skills
    	@keywords = [params[:profile][:keyword1],params[:profile][:keyword2],params[:profile][:keyword3],params[:profile][:keyword4],params[:profile][:keyword5]] 
	  
       	# For each tag name, check if exist in DB. If exist, increment the frecuency. Else create a new row in the DB
  		@keywords.each do |type|
  			if !type.empty?
	    		@tag = Tag.find(:first, :conditions => ['name = ?', type.strip() ])
	    		if !@tag.nil?
	      			@tag.update_attributes(:frequency => @tag.frequency + 1)
	    		else
	    			@tag = Tag.new
		      		@tag.name = type.strip()
		      		@tag.frequency = 1
		      		@tag.save
	    		end
	    	end     
  		end
	  		
  		@qualifiers = [params[:profile][:qualifier1],params[:profile][:qualifier2],params[:profile][:qualifier3],params[:profile][:qualifier4],params[:profile][:qualifier5]]
	  		
  		$i=0
  		@qualifiers.each do |qualifier|
	  		qualifier.split(",").each do |type|
		        @tag = Tag.find(:first, :conditions => ['name = ?', type.strip()])
		        if !@tag.nil?
	      			@tag.update_attributes(:frequency => @tag.frequency + 1)
	    		else
	    			@tag = Tag.new
		      		@tag.name = type.strip()
		      		@tag.frequency = 1
		      		@tag.save
	    		end
		    end		     
		    $i = $i + 1
		end
  	#END - Skills
             
    respond_to do |format|
      if @success
        format.html { redirect_to(@profile, :notice => 'Profile was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
  end
  
  def show
    @profile = Profile.find(params[:id])

     respond_to do |format|
       format.html # show.html.erb
       format.xml  { render :xml => @profile }
     end
  end  
end