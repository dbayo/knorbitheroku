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

class PeopleController < ApplicationController
  	before_filter :authenticate_user!

  	def index
      	@followers = current_user.following
      	
      	render :notice => notice
  	end
  
  	def mail
      	@message = Message.new
      	#follower = Follower.find(params[:id])
      	#@to = User.find_by_email(follower.email)
      	@to = User.find(params[:id])
      	render 'messages/send'
  	end
  	
  	def publicjobs
  	   @jobs = Job.where('user_id = ? and public = ? and status != ?', params[:id], 'Yes', 'draft')
  	   Contribution.where(:user_id => current_user.id).each do |contributor|
  	       @contributedjob = Job.where(:id => contributor.job_id, :public => "No", :user_id => params[:id])[0]
  	       @jobs << @contributedjob unless @contributedjob.nil?
  	   end
  	   Sharedjob.where(:to_email => User.find(current_user.id).email).each do |reader|
           @sharedjob = Job.where(:id => reader.job_id, :public => "No", :user_id => params[:id])[0]
           @jobs << @sharedjob unless @sharedjob.nil?
       end
       @user = User.find(params[:id])
  	   
  	   respond_to do |format|
          format.html
          format.xml
      end 
  	end
  	
  	def changegroup    
        @follower = Follower.find(:first, :conditions => ["follower_id = ? and followed_id = ?", current_user.id, params[:user_id]])      
        @follower.update_attributes(:group => params[:group])
    end
    
    def addnewgroup
         Group.create(:name => params[:group], :user_id => current_user.id) unless !Group.where(:name => params[:group], :user_id => current_user.id)[0].nil?
         
         @out = ''     
         @out.concat('<tr class="groups"><th>Groups</th></tr>') 
         @out.concat('<tr><td class="groups"><img alt="Move" src="/images/move.png" style="position:absolute; margin-left: -25px;">None</td></tr>') 
         @out.concat('<tr><td class="groups"><img alt="Move" src="/images/move.png" style="position:absolute; margin-left: -25px;">Favorite</td></tr>') 
         @out.concat('<tr><td class="groups"><img alt="Move" src="/images/move.png" style="position:absolute; margin-left: -25px;">Blocked</td></tr>')
         Group.where(:user_id => current_user.id).each do |group|
             @out.concat('<tr><td class="newgroups groups"><img alt="Move" src="/images/move.png" style="position:absolute; margin-left: -25px;">')
             @out.concat(group.name)
             @out.concat('</td></tr>')
         end
         @out.concat('<tr><td id="add_group">+ ADD GROUP</td></tr>')
         render :text => @out
    end
    
    def removegroup       
         Group.where(:name => params[:group], :user_id => current_user.id)[0].delete
        
         Follower.where(:follower_id => current_user.id, :group => params[:group]).each do |follower|
              follower.update_attributes(:group => "None")          
         end
    end
end
