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

class ContributionsController < ApplicationController
	def index
	    @contributions = Contribution.all
	
	    respond_to do |format|
	      format.html # index.html.erb
	      format.xml  { render :xml => @jobs }
	    end
  	end
  	
  	def remove
  	  @job = Job.find(params[:id])
  	  @message = current_user.sent_messages.create(:subject => "Contributor removed", :body => current_user.name+" has left to contribute with you", :to_id => @job.user_id, :read => false) unless current_user.id == @job.user.id
  	  
  		User.find(params[:user_id]).contribute.where(:job_id => params[:id])[0].delete
  		
  		@invitation = Invitations.where(:to_email => User.find(params[:user_id]).email, :job_id => params[:id])[0]
  		
  		Submittedinvitation.find(:all, :conditions => ['job_id = ? and to_email = ?', @invitation.job_id, @invitation.to_email ]).each do |inv|
          inv.delete
      end
      
  		@invitation.delete		
  		
  		respond_to do |format|
  		  if !params[:frommytrail].nil?
    	      format.html { redirect_to(jobs_path, :notice => "Job was successfully removed")}
            format.xml  { render :xml => @jobs }
    	  elsif current_user.id == @job.user.id
    	      format.html { redirect_to(job_path(@job)+'#tabs-4', :notice => "User was successfully removed")}
            format.xml  { render :xml => @jobs }
    	  else
    	      format.html { redirect_to(current_user, :notice => "User was successfully removed")}
            format.xml  { render :xml => @jobs }
    	  end
	    end
  	end
  	
  	def removeowner
  	  @job = Job.find(params[:id])
  	    
      @job.status = 'System'
      @job.save
      
      respond_to do |format|
          format.html { redirect_to(jobs_path, :notice => 'The Orbit '+@job.name+' was successfully removed')}
          format.xml  { render :xml => @jobs }
      end 
  	end
  	
  	def removereader
  	  @job = Job.find(params[:id])  
  	  Sharedjob.where(:to_email => User.find(params[:user_id]).email, :job_id => params[:id])[0].delete
  	  
  	  respond_to do |format|
          format.html { redirect_to(jobs_path, :notice => 'The Orbit '+@job.name+' was successfully removed')}
          format.xml  { render :xml => @jobs }
      end 
  	end
  	
  	def addtomynetwork
  		if !Follower.find(:first, :conditions => ['follower_id = ? and followed_id = ?', current_user.id, params[:id] ])
  			Follower.create(:follower_id => current_user.id , :followed_id => params[:id], :group => 'None')
  			@notice = "User was successfully added to my network"
  		else
  			@notice = "User alredy is in your network list"
  		end
  		
  		respond_to do |format|
	      format.html { redirect_to(invitations_job_path(params[:job_id])+'#tabs-4', :notice => @notice)}
	      format.xml  { render :xml => @jobs }
	    end
  	end
end
