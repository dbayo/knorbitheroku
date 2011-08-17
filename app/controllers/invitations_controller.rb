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

class InvitationsController < ApplicationController
    before_filter :authenticate_user!

	def accept
    # Accept an invitation
    
    @success = true
	  @invitation = Invitations.find(params[:id])

    @job = Job.find(:first, :conditions => ['id = ?', @invitation.job_id])
    
    @followed = User.find(:first, :conditions => ['email = ?', @invitation.to_email])
    
    if !@job.countriesexcluded.nil? and @job.countriesexcluded.split(", ").include?(@followed.profile.geospace)
        @success = false
    end
    
    @checkfollowedblocked = Follower.find(:first, :conditions => ['follower_id = ? and followed_id = ?', @job.user_id, @followed.id ])
    if !@checkfollowedblocked.nil? and @checkfollowedblocked.group == "blocked"
        @success = false
    end
    
    if @success
        if !Follower.find(:first, :conditions => ['follower_id = ? and followed_id = ?', @job.user_id, current_user.id ])
          Follower.create(:follower_id => @job.user_id , :followed_id => current_user.id, :group => 'None')
        end
        
        if !Follower.find(:first, :conditions => ['followed_id = ? and follower_id = ?', @job.user_id, current_user.id ])
          Follower.create(:followed_id => @job.user_id , :follower_id => current_user.id, :group => 'None')
        end
        
        Contribution.create(:user_id => current_user.id, :job_id => @invitation.job_id)
    
        @invitation.status = 'accepted'
    
        @invitation.save
        
        Submittedinvitation.find(:all, :conditions => ['job_id = ? and to_email = ?', @job.id, @invitation.to_email ]).each do |inv|
            inv.status = 'accepted'
            inv.save
        end 
    end
		
		respond_to do |format|
		  
		  if @success
          format.html { redirect_to(root_path) }
          format.xml  { render :xml => @jobs }
      else
          format.html { redirect_to(root_path, :notice => "blocked") }
          format.xml  { render :xml => @jobs }
      end
      
    end
	end
  
	def refuse
   
      # Refuse an invitation
  
  		@invitation = Invitations.find(params[:id])
  
  		@invitation.status = 'refused'
  
  		@invitation.save
  		
  		Submittedinvitation.find(:all, :conditions => ['job_id = ? and to_email = ?', @invitation.job_id, @invitation.to_email ]).each do |inv|
          inv.status = 'refused'
          inv.save
      end
  		
  		respond_to do |format|
        format.html { redirect_to(root_path) }
        format.xml  { render :xml => @jobs }
      end
	end

  	def update
		    @job = Job.find(params[:id])
		    
		    if @job.status == 'open'
		        #Invite to contribute a job
    		    @networkemails = params[:network]
            @followers = current_user.following
          
            if !@networkemails.nil? 
                @networkemails.each do |networkemail|
                    @inv = Invitations.find(:first, :conditions => ['job_id = ? and to_email = ?', params[:id], networkemail ])
                    if @inv.nil?   
                        Invitations.create(:from_id => current_user.id, :to_email => networkemail, :job_id => params[:id], :status => 'pending')
                        UserMailer.registration_confirmation( @job.name, @job.wiki, current_user, networkemail).deliver
                        Submittedinvitation.create(:from_id => current_user.id, :to_email => networkemail, :job_id => params[:id], :status => 'pending', :method => 'my network')
                    elsif Submittedinvitation.find(:first, :conditions => ['job_id = ? and from_id = ? and to_email = ?', params[:id], current_user.id, networkemail ]).nil?  
                        Submittedinvitation.create(:from_id => current_user.id, :to_email => networkemail, :job_id => params[:id], :status => @inv.status, :method => 'my network')
                    end
                end
            end
          
            @emails = params[:sendto].split(",")
            @emails.each do |email|
                @sendto = email.strip()
                @inv = Invitations.find(:first, :conditions => ['job_id = ? and to_email = ?', params[:id], @sendto ])
                if @inv.nil? && @sendto != current_user.email && @sendto != @job.user.email
                    Invitations.create(:from_id => current_user.id, :to_email => @sendto, :job_id => params[:id], :status => 'pending')
                    UserMailer.registration_confirmation(@job.name, @job.wiki, current_user, email).deliver
                    Submittedinvitation.create(:from_id => current_user.id, :to_email => @sendto, :job_id => params[:id], :status => 'pending', :method => 'written')
                elsif @sendto != current_user.email && @sendto != @job.user.email && Submittedinvitation.find(:first, :conditions => ['job_id = ? and from_id = ? and to_email = ?', params[:id], current_user.id, @sendto ]).nil?  
                    Submittedinvitation.create(:from_id => current_user.id, :to_email => @sendto, :job_id => params[:id], :status => @inv.status, :method => 'written')
                end
            end
        end

     	  respond_to do |format|
         	  format.html { redirect_to(invitations_job_path(@job)+"#tabs-3", :notice => "Users were sucessfully invited") }
        	  format.xml  { head :ok }
       	end
  	end  
end
