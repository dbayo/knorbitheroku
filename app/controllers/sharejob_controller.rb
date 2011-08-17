class SharejobController < ApplicationController
    def show
        @job = Job.find(params[:id])
        @contributors = Contribution.find(:all, :conditions => ['job_id = ?', params[:id] ])
        
        @sharedjobs = Sharedjob.find(:all, :conditions => ['job_id = ? and method = ? and from_id = ?', params[:id], "written", current_user.id])
        @followers = current_user.following
        
      
        respond_to do |format|
          format.html { render :notice => notice}# show.html.erb
          format.xml  { render :xml => @job }
        end
    end
    
    def update
      @job = Job.find(params[:id])
      @networkemails = params[:network]
        # Send an invitation to share a job
       if !@networkemails.nil?
           @networkemails.each do |networkemail|
              if Sharedjob.find(:first, :conditions => ['job_id = ? and to_email = ?', params[:id], networkemail ]).nil?   
                  Sharedjob.create(:from_id => current_user.id, :to_email => networkemail, :job_id => params[:id], :method => "My network")           
              end
           end
       end
    
       @emails = params[:sendto].split(",")
       @emails.each do |email|
           @sendto = email.strip()
           if Contribution.find(:first, :conditions => ['user_id = ? and job_id = ?', User.find_by_email(@sendto), params[:id] ]).nil? and Sharedjob.find(:first, :conditions => ['job_id = ? and to_email = ?', params[:id], @sendto ]).nil? and @sendto != current_user.email   
               Sharedjob.create(:from_id => current_user.id, :to_email => @sendto, :job_id => params[:id], :method => "written")
           end
       end
       respond_to do |format|
          format.html { redirect_to(sharejob_path(params[:id])) }
      end
    end
    
    def addtomytrail
        @job = Job.where(:wikispace => params[:id])[0]
        Sharedjob.create(:from_id => 0, :to_email => current_user.email, :job_id => @job.id, :method => "Add to My Trail")
        respond_to do |format|
            format.html {redirect_to(@job.wiki, :notice => 'Job was added successfully to My Trail')}
        end
    end
end
