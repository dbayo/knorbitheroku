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

class UsersController < ApplicationController
  before_filter :authenticate_user!

  def show
  	@user = current_user
    @jobs = @user.jobs.paginate(:page => params[:page], :conditions => ['status != ? and status != ?', 'closed', 'System'])
	  @contributions = @user.contribute.paginate(:page => params[:page])
    @invitations = Invitations.find(:all, :conditions => ['status = ? and to_email = ?', 'pending', current_user.email ])
    @account = @user.account
    @profile = @user.profile    
    #@activities = @user.feed.paginate(:page => params[:page])
    
    #Test
    #@access_tolken = "AItOawmU8sSnfuzZjf9R-z4QMwg-6ga5-dhSLGk"
    #@client = PortableContacts::Client.new "http://www-opensocial.googleusercontent.com/api/people", @access_token
    #@profile = @client.me
    #puts @profile.display_name
    
    
     respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @user }
      end
  end
  
  def index
      @users = User.all
  end

end
