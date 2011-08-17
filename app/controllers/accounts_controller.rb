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

class AccountsController < ApplicationController
  before_filter :authenticate_user!

  # GET /account/new
  # GET /account/new.xml
  def new
    @account  = Account.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @job }
    end
  end
  
  def edit
    @account = Account.find(params[:id])
   
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @job }
    end      
  end
  
  def create
       @account  = current_user.account.build(params[:account])
       respond_to do |format|
         if @account.save
           format.html { redirect_to(@account, :notice => 'Account was successfully created.') }
           format.xml  { render :xml => @account, :status => :created, :location => @account }
         else
           format.html { render :action => "new" }
           format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
         end
       end
  end

  def update
    params[:account][:language] = params[:fromBox].join(", ") unless params[:fromBox].nil?    
    @account = current_user.account

    respond_to do |format|
      if @account.update_attributes(params[:account])
        format.html { redirect_to('/accounts/'+@account.id.to_s, :notice => 'Account was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
  end
  
  def show
     @account = Account.find(params[:id])
     
     @i = 0
     @i = @i+1 if current_user.profile.qualifier1.split(",").length == 1
     @i = @i+2 if current_user.profile.qualifier1.split(",").length >= 2
     @i = @i+1 if current_user.profile.qualifier2.split(",").length == 1
     @i = @i+2 if current_user.profile.qualifier2.split(",").length >= 2
     @i = @i+1 if current_user.profile.qualifier3.split(",").length == 1
     @i = @i+2 if current_user.profile.qualifier3.split(",").length >= 2
     @i = @i+1 if current_user.profile.qualifier4.split(",").length == 1
     @i = @i+2 if current_user.profile.qualifier4.split(",").length >= 2
     @i = @i+1 if current_user.profile.qualifier5.split(",").length == 1
     @i = @i+2 if current_user.profile.qualifier5.split(",").length >= 2

     respond_to do |format|
       format.html # show.html.erb
       format.xml  { render :xml => @account }
     end
  end
end
