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

class JobsController < ApplicationController
  	before_filter :authenticate_user!
  
  	# GET /jobs
  	# GET /jobs.xml
  	def index
    	@jobs = Job.find(:all, :conditions => ['status = ? and user_id = ?', 'closed', current_user.id])
    	@contributions = current_user.contribute
    	@sharedjobs = Sharedjob.find(:all, :conditions => ['to_email = ?', current_user.email])

    	respond_to do |format|
      		format.html # index.html.erb
      		format.xml  { render :xml => @jobs }
   	 	end
  	end

  # GET /jobs/1
  # GET /jobs/1.xml
  def show
    @job = Job.find(params[:id])
    @job.duration = @job.duration / 168
    @contributors = Contribution.find(:all, :conditions => ['job_id = ?', params[:id] ])
    @space = Space.where(:wiki_name => @job.wikispace)[0]
    @home = @space.documents.where('name = ?',"Home")[0] 
    
    # INVITATIONS   
	    @submittedinv = Submittedinvitation.find(:all, :conditions => ['job_id = ? and from_id = ? and method = ?', params[:id], current_user.id, 'written'])	      
	    @followers = current_user.following   
    # INVITATIONS(END)
    
    respond_to do |format|
        format.html { render :notice => notice}
        format.xml  { render :xml => @job}
    end
  end
  
  def invitations
    @job = Job.find(params[:id])

    # INVITATIONS
      @submittedinv = Submittedinvitation.find(:all, :conditions => ['job_id = ? and from_id = ? and method = ?', params[:id], current_user.id, 'written'])
	       
	    @followers = current_user.following
    
    # INVITATIONS(END)

    respond_to do |format|
      format.html { render :notice => notice}
      format.xml  { render :xml => @job }
    end
  end

  # GET /jobs/new
  # GET /jobs/new.xml
  def new
    @job = Job.new
   
    @tagsBD = Hash.new

    respond_to do |format|
      format.html  # new.html.erb
      format.xml  { render :xml => @job }
    end
  end

  # POST /jobs
  # POST /jobs.xml
  def create
  	params[:job][:duration] = params[:job][:duration].to_i * 168
    @job = current_user.jobs.build(params[:job])
    
    @job.wiki = '#'
    @job.status = 'draft'
    
	  @job.language = "English"
	  @job.favorite = "No"
	  @job.viral = "Yes"
    @job.smart = "No"
    @job.checkmarkskills = "No"
    @job.checkmarksections = "No"
    @job.template = "Section 1,Section 2"
    @job.keyword1 = ""
    @job.keyword2 = ""
    @job.keyword3 = ""
    @job.keyword4 = ""
    @job.keyword5 = ""
    @job.qualifier1 = ""
    @job.qualifier2 = ""
    @job.qualifier3 = ""
    @job.qualifier4 = ""
    @job.qualifier5 = ""
    
    if !Job.where(:name => @job.name, :user_id => current_user.id)[0].nil?
        @i = 2
        while Job.where(:name => @job.name+"(" + @i.to_s + ")").any? do
             @i = @i + 1
        end
        @job.name = @job.name+"(" + @i.to_s + ")"  
    end
    
    @success = @job.save
    # check if the fields of the form are empty
    if @success
      	wiki_name = UUIDTools::UUID.random_create.to_s().gsub("-","_")
      	
      	@space = Space.create(:name => @job.name, :wiki_name => wiki_name.to_s, :status => "open")
      	
      	@space.content = "<div id='index'><ol>"
        "Section 1,Section 2".split(',').each do |pageName|
            @newpage = @space.documents.new(:name => pageName, :status => "open")
            @newpage.save
            @space.content = @space.content + '<li><a href="/spaces/'+wiki_name+'/documents/'+@newpage.id.to_s+'">'+pageName+'</a></li>'
        end
        @space.content = @space.content + "</ol></div>"
        @space.save
      	
      	@job.update_attributes(:wiki => '/spaces/'+wiki_name, :wikispace => wiki_name )

      	@activity = current_user.activities.create(:job_id => @job.id, :message => "Job "+ @job.name + " created. ") 
    end
    
    # TODO Process errors
    respond_to do |format|
      if @success
        format.html { redirect_to(job_path(@job)+'#tabs-0', :notice => 'Job was successfully created') }
        format.xml  { render :xml => @job, :status => :created, :location => @job }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.xml
  def update
  	params[:job][:countriesexcluded] = params[:fromBox].join(", ") unless params[:fromBox].nil?
  	
  	# Delete ',' of the qualifiers
    params[:job][:qualifier1].gsub!(/,\s*\z/, '') unless params[:job][:qualifier1].nil?
    params[:job][:qualifier2].gsub!(/,\s*\z/, '') unless params[:job][:qualifier2].nil?
    params[:job][:qualifier3].gsub!(/,\s*\z/, '') unless params[:job][:qualifier3].nil?
    params[:job][:qualifier4].gsub!(/,\s*\z/, '') unless params[:job][:qualifier4].nil?
    params[:job][:qualifier5].gsub!(/,\s*\z/, '') unless params[:job][:qualifier5].nil?
    
    @job = Job.find(params[:id])
    
    # INVITATIONS
      @submittedinv = Submittedinvitation.find(:all, :conditions => ['job_id = ? and from_id = ? and method = ?', params[:id], current_user.id, 'written'])       
      @followers = current_user.following
    # INVITATIONS
    
    @oldtemplate = @job.template
    params[:job][:duration] = params[:job][:duration].to_i * 168 unless params[:job][:duration].nil?
    
    if @job.name != params[:job][:name] and !Job.where(:name => params[:job][:name], :user_id => current_user.id)[0].nil?
        @job.errors.add_to_base("Already exists another Orbit with the same name")
    else
        @success = @job.update_attributes(params[:job])
    end 
    
    if @success
      
    	  # Tab invitations (send an invitation to contribute a job)
    		@networkemails = params[:network]
	    	@followers = current_user.following
			
		    if @job.status == 'draft'			
    				if !@networkemails.nil?
    			      @networkemails.each do |networkemail|
    			          @inv = Invitations.find(:first, :conditions => ['job_id = ? and to_email = ?', params[:id], networkemail ])
    						    if @inv.nil?   
    				            Invitations.create(:from_id => current_user.id, :to_email => networkemail, :job_id => params[:id], :status => 'invited')
    				            Submittedinvitation.create(:from_id => current_user.id, :to_email => networkemail, :job_id => params[:id], :status => 'invited', :method => 'my network')
    				        elsif Submittedinvitation.find(:first, :conditions => ['job_id = ? and from_id = ? and to_email = ?', params[:id], current_user.id, networkemail ]).nil?  
    				            Submittedinvitation.create(:from_id => current_user.id, :to_email => networkemail, :job_id => params[:id], :status => @inv.status, :method => 'my network')
    				      	end
    					  end
    			  end
    			    
  			    @emails = params[:sendto].split(",")
  			    @emails.each do |email|
  			      	@sendto = email.strip()
  			      	@inv = Invitations.find(:first, :conditions => ['job_id = ? and to_email = ?', params[:id], @sendto ])
  			      	if @inv.nil? and @sendto != current_user.email
    			        	Invitations.create(:from_id => current_user.id, :to_email => @sendto, :job_id => params[:id], :status => 'invited')
    			        	Submittedinvitation.create(:from_id => current_user.id, :to_email => @sendto, :job_id => params[:id], :status => 'invited', :method => 'written')
  			        elsif Submittedinvitation.find(:first, :conditions => ['job_id = ? and from_id = ? and to_email = ?', params[:id], current_user.id, @sendto ]).nil? and @sendto != current_user.email
                    Submittedinvitation.create(:from_id => current_user.id, :to_email => @sendto, :job_id => params[:id], :status => @inv.status, :method => 'written')
  			      	end
  			    end			
			  elsif	@job.status == 'open'
				    if !@networkemails.nil? 
					      @networkemails.each do |networkemail|
					         @inv = Invitations.find(:first, :conditions => ['job_id = ? and to_email = ?', params[:id], networkemail ])
						        if @inv.nil?   
      				        	@invitation = Invitations.create(:from_id => current_user.id, :to_email => networkemail, :job_id => params[:id], :status => 'pending')
      				        	Submittedinvitation.create(:from_id => current_user.id, :to_email => networkemail, :job_id => params[:id], :status => 'pending', :method => 'my network')
      				        	@sendto = User.where(:email => networkemail)[0]
      				        	if @sendto.nil?
      				        	   UserMailer.nonorbituser( @job, current_user, @invitation, networkemail).deliver
      				        	else
      				        	   UserMailer.orbituser( @job, current_user, @invitation, @sendto ).deliver
      				        	end
      				      elsif Submittedinvitation.find(:first, :conditions => ['job_id = ? and from_id = ? and to_email = ?', params[:id], current_user.id, networkemail ]).nil?  
                        Submittedinvitation.create(:from_id => current_user.id, :to_email => networkemail, :job_id => params[:id], :status => @inv.status, :method => 'written')				        	
				      	    end
					      end
			      end
			    
  			    @emails = params[:sendto].split(",")
  			    @emails.each do |email|
  			      	@sendto = email.strip()
  			      	@inv = Invitations.find(:first, :conditions => ['job_id = ? and to_email = ?', params[:id], @sendto ])
  			      	if @inv.nil? and @sendto != current_user.email   
    			        	@invitation = Invitations.create(:from_id => current_user.id, :to_email => @sendto, :job_id => params[:id], :status => 'pending')
    			        	Submittedinvitation.create(:from_id => current_user.id, :to_email => @sendto, :job_id => params[:id], :status => 'pending', :method => 'written')
    			        	@sendto = User.where(:email => email)[0]
    			        	if @sendto.nil?
                       UserMailer.nonorbituser(@job, current_user, @invitation, email).deliver
                    else
                       UserMailer.orbituser(@job, current_user, @invitation, @sendto).deliver
                    end
                elsif Submittedinvitation.find(:first, :conditions => ['job_id = ? and from_id = ? and to_email = ?', params[:id], current_user.id, @sendto ]).nil? and @sendto != current_user.email
                    Submittedinvitation.create(:from_id => current_user.id, :to_email => @sendto, :job_id => params[:id], :status => @inv.status, :method => 'written')      	
  			      	end
  			    end
			   end
    	
    	if @job.status == "draft"  
      	# Skills
      	  # Can not be an empty main keyword with details
              params[:job][:qualifier1] = "" unless !params[:job][:keyword1].empty?
              params[:job][:qualifier2] = "" unless !params[:job][:keyword2].empty?
              params[:job][:qualifier3] = "" unless !params[:job][:keyword3].empty?
              params[:job][:qualifier4] = "" unless !params[:job][:keyword4].empty?
              params[:job][:qualifier5] = "" unless !params[:job][:keyword5].empty?
          # END - Can not be an empty main keyword with details
      	
      	  # The main keywork can not be repeated on the detailed tag for that keyword and The maximun number of "detail" tags is 10
              params[:job][:qualifier1] = (params[:job][:qualifier1].split(",").collect{|x| x.strip} - params[:job][:keyword1].split(",").collect{|x| x.strip}).uniq.first(10).join(", ") unless params[:job][:qualifier1].empty?
              params[:job][:qualifier2] = (params[:job][:qualifier2].split(",").collect{|x| x.strip} - params[:job][:keyword2].split(",").collect{|x| x.strip}).uniq.first(10).join(", ") unless params[:job][:qualifier2].empty?
              params[:job][:qualifier3] = (params[:job][:qualifier3].split(",").collect{|x| x.strip} - params[:job][:keyword3].split(",").collect{|x| x.strip}).uniq.first(10).join(", ") unless params[:job][:qualifier3].empty?
              params[:job][:qualifier4] = (params[:job][:qualifier4].split(",").collect{|x| x.strip} - params[:job][:keyword4].split(",").collect{|x| x.strip}).uniq.first(10).join(", ") unless params[:job][:qualifier4].empty?
              params[:job][:qualifier5] = (params[:job][:qualifier5].split(",").collect{|x| x.strip} - params[:job][:keyword5].split(",").collect{|x| x.strip}).uniq.first(10).join(", ") unless params[:job][:qualifier5].empty?
          # END - The main keywork can not be repeated on the detailed tag for that keyword and The maximun number of "detail" tags is 10
                   
  	    	@keywords = [params[:job][:keyword1],params[:job][:keyword2],params[:job][:keyword3],params[:job][:keyword4],params[:job][:keyword5]]
  	    	@qualifiers = [params[:job][:qualifier1],params[:job][:qualifier2],params[:job][:qualifier3],params[:job][:qualifier4],params[:job][:qualifier5]]
  	    	
  	    	# Every main keywork should be unique
  	    	if !@keywords.uniq!.nil?
  	    	    @keywords_old = [params[:job][:keyword1],params[:job][:keyword2],params[:job][:keyword3],params[:job][:keyword4],params[:job][:keyword5]] 
  	    	    $i = 0;
              $j = 0;
              
              while $i < @keywords_old.size  do
                 if @keywords[$j].nil?
                    @keywords_old.delete_at($j)
                    @qualifiers.delete_at($j)
                 elsif @keywords_old[$i] == @keywords[$j]
                    $j +=1;
                    $i +=1;
                 else
                    @qualifiers[@keywords_old.index(@keywords_old[$i])] = @qualifiers[@keywords_old.index(@keywords_old[$i])] + ', ' + @qualifiers[$j]
                    @keywords_old.delete_at($j)             
                    @qualifiers.delete_at($j)
                 end     
              end
              
              # The main keywork can not be repeated on the detailed tag for that keyword and The maximun number of "detail" tags is 10
                  @qualifiers[0] = (@qualifiers[0].split(",").collect{|x| x.strip} - @keywords_old[0].split(",").collect{|x| x.strip}).uniq.first(10).join(", ") unless @qualifiers[0].nil?
                  @qualifiers[1] = (@qualifiers[1].split(",").collect{|x| x.strip} - @keywords_old[1].split(",").collect{|x| x.strip}).uniq.first(10).join(", ") unless @qualifiers[1].nil?
                  @qualifiers[2] = (@qualifiers[2].split(",").collect{|x| x.strip} - @keywords_old[2].split(",").collect{|x| x.strip}).uniq.first(10).join(", ") unless @qualifiers[2].nil?
                  @qualifiers[3] = (@qualifiers[3].split(",").collect{|x| x.strip} - @keywords_old[3].split(",").collect{|x| x.strip}).uniq.first(10).join(", ") unless @qualifiers[3].nil?
                  @qualifiers[4] = (@qualifiers[4].split(",").collect{|x| x.strip} - @keywords_old[4].split(",").collect{|x| x.strip}).uniq.first(10).join(", ") unless @qualifiers[4].nil?
              # END - The main keywork can not be repeated on the detailed tag for that keyword and The maximun number of "detail" tags is 10
              
              @job.update_attributes(:keyword1 => @keywords_old[0],:keyword2 => @keywords_old[1],:keyword3 => @keywords_old[2],:keyword4 => @keywords_old[3],:keyword5 => @keywords_old[4],
                                     :qualifier1 => @qualifiers[0],:qualifier2 => @qualifiers[1],:qualifier3 => @qualifiers[2],:qualifier4 => @qualifiers[3],:qualifier5 => @qualifiers[4])       
  	    	end
  	    	# END - Every main keywork should be unique
  	    	 	  
  	       	# For each tag name, check if exist in DB. If exist, increment the frecuency. Else create a new row in the DB
  	  		@keywords_old.each do |type|
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
  		end
  		
  		#Templates
  		  if !params[:pagesDeleted].nil? && !params[:pagesDeleted].empty?
           @space = Space.find(:first, :conditions => ['"wiki_name" = ?', @job.wikispace])
           params[:pagesDeleted].split(',').each do |pageDeleted|
              @document = @space.documents.where(:name => pageDeleted)[0]
              @document.delete unless @document.nil?
           end          
        end
        
  			if @oldtemplate != params[:templatecontent]
  			  @space = Space.find(:first, :conditions => ['"wiki_name" = ?', @job.wikispace])
  			  Templates.create(:name => params[:newtemplatename], :content => @job.template, :user_id => current_user.id) unless (!params[:newtemplatename].nil? and params[:newtemplatename].empty?) or !Templates.find(:first, :conditions => ['content = ? and (user_id = ? or user_id = ?)',@job.template, current_user.id, 0]).nil?
  			  
  			  if !params[:changedNames].nil?
  			     #Change title of the sections
  			     params[:changedNames].split(',').each do |pageDeleted|
  			        @section = params[:changedNames].split('->>')

  			        @document = @space.documents.where(:name => @section[0])[0]
  			        if @document.nil?
  			           @newpage = @space.documents.create(:name => @section[1], :status => "open")
  			        else
  			           @document.update_attributes(:name => @section[1]) 
  			        end
  			        		        
             end     
  			  elsif !@oldtemplate.nil?
  			     #Change template
  			     @oldtemplate.split(',').each do |pageDeleted|
                 @document = @space.documents.where(:name => pageDeleted)[0]
                 @document.delete
             end
  			  end
  				
  				@space.content = "<div id='index'><ol>"
  				@job.template.split(',').each do |pageName|
  					if @space.documents.where('name = ?',pageName)[0].nil?
  						@newpage = @space.documents.new(:name => pageName, :status => "open")
  						@newpage.save
  						@space.content = @space.content + '<li><a href="/spaces/'+@job.wikispace+'/documents/'+@newpage.id.to_s+'">'+pageName+'</a></li>'
  					else
  						@space.content = @space.content + '<li><a href="/spaces/'+@job.wikispace+'/documents/'+@space.documents.where('name = ?',pageName)[0].id.to_s+'">'+pageName+'</a></li>'
  					end
  				end
  				@space.content = @space.content + "</ol></div>"
  				@space.save
  			end
  		
  		#END - Templates
  		
  		#Versions
  			if !params[:nameversion].nil? && !params[:nameversion].empty?
  			  @content = @space.content	    
	  			@sections = Space.where(:wiki_name => @job.wikispace)[0].documents
	  			@sections.each do |doc|
	  				  version_hash = UUIDTools::UUID.timestamp_create.to_s
			      	@version = doc.versions.create(:content => doc.content, :version => version_hash, :user_id => current_user.id)
			      	@version.save
			      	
			      	@content = @content.gsub('">'+doc.name+'<','/versions/'+version_hash+'">'+doc.name+'<')
	  			end
	  			
	  			version_hash = UUIDTools::UUID.timestamp_create
	      	@spaceversion = Spaceversion.create(:content => @content, :name => params[:nameversion], :user_id => current_user.id, :space_id => @space.id)
	      	@spaceversion.save
		   end
  		#END - Versions
  		
  		#Rewards
  			if !params[:points].nil? 
	  			params[:points].each do |rd|
		  				@reward = Rewards.find(:first, :conditions => ['owner_id = ? and contributor_id = ? and job_id = ?', current_user.id, rd[0], @job.id ])
						  if @reward.nil?   
				        	Rewards.create(:owner_id => current_user.id, :contributor_id => rd[0], :job_id => @job.id, :points => rd[1])
				      else
				        	@reward.update_attributes(:points => rd[1].to_i)
				      end
				  end
  			end
  			
  		#END - Rewards
  		
  		# Modify the name of a space
  			 @space = Space.find(:first, :conditions => ['wiki_name = ?', @job.wikispace])
			   @space.update_attributes(:name => @job.name)
		  # END - Modify the name of a space
  		
  		 if @success
         	@activity = current_user.activities.create(:job_id => @job.id, :message => "Job "+ @job.name + " updated. ")
     	 end
    end
    respond_to do |format|
      if params[:selectedbutton] == 'edit'
        format.html {redirect_to(@job.wiki)}
      elsif params[:selectedbutton] == 'launch' and !@job.template.nil? and !@job.template.empty? and Invitations.where(:job_id => @job.id ).any? and @job.checkmarkskills == "Yes"
        format.html {redirect_to(open_job_path(@job)+'?tabSelected='+params[:tabSelected])}
      elsif params[:selectedbutton] == 'Stop contributions'
        format.html {redirect_to(internaltimeout_job_path(@job))}
      elsif params[:selectedbutton] == 'Done'
        format.html {redirect_to(close_job_path(@job))}  
      elsif params[:selectedbutton] == 'Replication'
        format.html {redirect_to(replication_job_path(@job))}
      elsif @success
        format.html { redirect_to('/jobs/'+@job.id.to_s+'#tabs-'+params[:tabSelected], :notice => 'Job was successfully updated') }
        format.xml  { head :ok }     
      else
        format.html { render :action => "show"}
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  	def open	
  		  @job = Job.find(params[:id])
  		  @space = Space.where(:wiki_name => @job.wikispace)[0]
  		  @home = Document.where('name = ? and space_id = ?',"Home", @space.id)[0]
		    
  		  @job.save
  	
  			@success = true   
		    #Send invitations                   
		 
		    @invitations = Invitations.find(:all, :conditions => ['job_id = ? and status = ?', params[:id], 'invited' ])
		    @invitations.each do |invitation|
		        @sendto = User.where(:email => invitation.to_email)[0]
		        if @sendto.nil?
               UserMailer.nonorbituser( @job, current_user, invitation, invitation.to_email).deliver
            else
               UserMailer.orbituser( @job, current_user, invitation, @sendto ).deliver
            end
		        invitation.status = 'pending'
		        invitation.save
		    end
		    
		    @submittedinv = Submittedinvitation.find(:all, :conditions => ['job_id = ? and status = ?', params[:id], 'invited' ])
        @submittedinv.each do |subinv|
            subinv.status = 'pending'
            subinv.save
        end
    
		    #Set open date for the internal timeout
		    @job.date = Date.today + ( @job.duration / 24 )
		    
		    #Change the status job
		    @job.status = 'open'
		    
		    #TODO frooze the wiki main page
		    #TODO Posting credit for the user is decreased
    
		    @job.save
		    @activity = current_user.activities.create(:job_id => @job.id, :message => "Job "+ @job.name + " open. ")

		    respond_to do |format|
	      	  if @success
		            format.html { redirect_to(job_path(@job)+'#tabs-'+params[:tabSelected], :notice => 'Job was successfully open') }
		            format.xml  { render :xml => @job, :status => :created, :location => @job }
	      	  else
		            format.html { render :controller => 'job', :action => 'show', :job => @job }
		            format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
	     	    end
	      end
  	end
  	
	def internaltimeout
		  @job = Job.find(params[:id])
	    #Change the status job
	    @job.status = 'Ready for reward'
	    
	    #TODO frooze the wiki main page
	    #TODO Posting credit for the user is decreased
	    
	    @job.save
	    
	    Submittedinvitation.where(:job_id => @job.id, :status => 'pending').each do |invitation|         
          invitation.status = 'expired'
          invitation.save
      end
      
      Invitations.where(:job_id => @job.id, :status => 'pending').each do |invitation|         
          invitation.status = 'expired'
          invitation.save
      end
	    
	    @activity = current_user.activities.create(:job_id => @job.id, :message => "Job "+ @job.name + " : Contributing dealine timeout . ")
	    
	    respond_to do |format|
	      if Contribution.find(:all, :conditions => ['job_id = ?', @job.id ]).any?
    	      format.html { redirect_to(job_path(@job)+'#tabs-6', :notice => 'Job was successfully closed') }
    	      format.xml  { render :xml => @job }
    	  else
    	      format.html { redirect_to(close_job_path(@job)) }
            format.xml  { render :xml => @job }
    	  end
	    end
	end
  
  	def close
  	  @NN = Rewards.where(:job_id => params[:id], :points => 0).count
  	  @NF = Rewards.where(:job_id => params[:id], :points => 1).count
  	  @NG = Rewards.where(:job_id => params[:id], :points => 2).count
  	  @NE = Rewards.where(:job_id => params[:id], :points => 3).count
  	  @NX = Rewards.where(:job_id => params[:id], :points => 4).count
  	  
  	  @total_peers = @NF + @NG + @NE + @NX + @NN
  	  
      @P = [50, 10 * (@NF + @NG + @NE + @NX + @NN) ].max
      @Maxg = [0.5 * @P, 100 ].min
      @Maxf = [0.3 * @P, 100 ].min
  	  
  	  #Exceptional contributors
  	  if @NX != 0
  	      @Px = [(@P*10) /  ( @NF*1 + @NG*3 + @NE*6 + @NX*10), 100].min
          @P = @P - (@Px * @NX)      
          Rewards.where(:job_id => params[:id], :points => 4).each do |exceptional|          
               exceptional.update_attributes(:total => @Px )  
          end
  	  end
  	  
  	  #Excelent contributors
  	  if @NE != 0
          @Pe = [(@P*6) /  ( @NF*1 + @NG*3 + @NE*6 ), 100].min
          @P = @P - (@Pe * @NE)      
          Rewards.where(:job_id => params[:id], :points => 3).each do |exceptional|          
               exceptional.update_attributes(:total => @Pe )  
          end
      end
      
      #Good contributors
      if @NG != 0
          @Pg = [(@P*3) /  ( @NF*1 + @NG*3), @Maxg].min
          @P = @P - (@Pg * @NG)      
          Rewards.where(:job_id => params[:id], :points => 2).each do |exceptional|          
               exceptional.update_attributes(:total => @Pg )  
          end
      end
      
      #Fair contributors
      if @NF != 0
          @Pf = [ (@P / @NF), @Maxf].min    
          Rewards.where(:job_id => params[:id], :points => 1).each do |exceptional|          
               exceptional.update_attributes(:total => @Pf )  
          end
      end
  	 
    	@job = Job.find(params[:id])
	   
	    #Change the status job
	    @job.status = 'closed'
	      
	    @job.save
	    
	    @activity = current_user.activities.create(:job_id => @job.id, :message => "Job "+ @job.name + " closed. ")
	    
	    
	    respond_to do |format|
	      format.html { redirect_to(@job, :notice => 'Job was successfully closed and moved in "My trails"') }
	      format.xml  { render :xml => @job }
	    end
       
  	end
  

  	def replication
	    @job_old = Job.find(params[:id])  
	    
	    @job = current_user.jobs.build
	    @i = 2
	    while Job.where(:name => @job_old.name+"(" + @i.to_s + ")").any? do
	         @i = @i + 1
	    end
	    @job.name = @job_old.name+"(" + @i.to_s + ")"
	    @job.description = @job_old.description
	    @job.wiki = @job_old.wiki
	    @job.wikispace = @job_old.wikispace
	    @job.language = @job_old.language
	    @job.duration = @job_old.duration
	    @job.maxcontributors = @job_old.maxcontributors
	    @job.countriesexcluded = @job_old.countriesexcluded
	    @job.template = @job_old.template
	    @job.status = 'draft'
	    @job.favorite = @job_old.favorite
	    @job.viral = @job_old.viral
	    @job.public = @job_old.public
	    @job.smart = @job_old.smart
	    @job.checkmarkskills = 'No'
	    @job.checkmarksections = 'No'
	    @job.keyword1 = @job_old.keyword1
	    @job.keyword2 = @job_old.keyword2
	    @job.keyword3 = @job_old.keyword3
	    @job.keyword4 = @job_old.keyword4
	    @job.keyword5 = @job_old.keyword5
	    @job.qualifier1 = @job_old.qualifier1
	    @job.qualifier2 = @job_old.qualifier2
	    @job.qualifier3 = @job_old.qualifier3
	    @job.qualifier4 = @job_old.qualifier4
	    @job.qualifier5 = @job_old.qualifier5
	    
	    @job.save
	    
	    #Invite old peers
	    @job_old.contributed.each do |contribution|
	        if User.find(contribution.user_id) == current_user
              Invitations.create(:from_id => current_user.id, :to_email => User.find(@job_old.user_id).email, :job_id => @job.id, :status => 'invited') unless @job_old.status == 'System'
              Submittedinvitation.create(:from_id => current_user.id, :to_email => User.find(@job_old.user_id).email, :job_id => @job.id, :status => 'invited', :method => 'my network') unless @job_old.status == 'System'
	        else    
              Invitations.create(:from_id => current_user.id, :to_email => User.find(contribution.user_id).email, :job_id => @job.id, :status => 'invited')
              Submittedinvitation.create(:from_id => current_user.id, :to_email => User.find(contribution.user_id).email, :job_id => @job.id, :status => 'invited', :method => 'my network')         
              
              if !Follower.find(:first, :conditions => ['followed_id = ? and follower_id = ?', contribution.user_id, current_user.id ])
                Follower.create(:followed_id => contribution.user_id , :follower_id => current_user.id, :group => "none")
              end
          end
      end
	    
	    #Create new space.
	    wiki_name = UUIDTools::UUID.random_create.to_s().gsub("-","_") 
	    @spaceold = Space.find(:first, :conditions => ['wiki_name = ?', @job.wikispace])  	
	  	@space = Space.create(:name => @job.name, :wiki_name => wiki_name.to_s, :status => "open")
	  	
	  	#Get values of the old documents and create new documents for the new space.
	  	@spaceold.documents.each do |doc|
	  		@space.documents.create(:name => doc.name, :content => doc.content, :status => "open")
	  	end
	  	
	  	#Create index page of the wiki
		  @content = "<div id='index'><ol>"
		  @job.template.split(',').each do |pageName|
			   @content = @content + '<li><a href="/spaces/'+wiki_name+'/documents/'+@space.documents.where('name = ?',pageName)[0].id.to_s+'">'+pageName+'</a></li>'
		  end
		  @content = @content + "</ol></div>"
		  @space.update_attributes(:content => @content)
		
		  #Update link to the wiki
	  	@job.update_attributes(:wiki => '/spaces/'+wiki_name, :wikispace => wiki_name )
	
	    respond_to do |format|
	      format.html { redirect_to(@job, :notice => 'Job was successfully created') }
	      format.xml  { render :xml => @job }
	    end 
  	end
  	
  	 def remove
        @job = Job.find(params[:id])
    
        @space = Space.find(:first, :conditions => ['wiki_name = ?', @job.wikispace])
        @space.documents.each do |doc|
            doc.destroy
        end
    
        @space.destroy
    
        Invitations.where(:job_id => @job.id).each do |inv|
            inv.delete
        end
    
        Submittedinvitation.where(:job_id => @job.id).each do |inv|
            inv.delete
        end
    
        @job.destroy
    
        respond_to do |format|
            format.html { redirect_to( current_user, :notice => 'The Orbit '+@job.name+' was successfully deleted') }
            format.xml  { render :xml => @job }
        end
    end
  
  	def search
  		@jobs = Job.search(current_user, params[:search])
  	
  	 	respond_to do |format|
      		format.html
      		format.xml  { render :xml => @job }
    	end 
  	end 
  	
  	def template
  		
  		respond_to do |format|
      		format.js
    	end 
  	end
  	
  	def skilltagcloudajax
  	    if (params[:cat] == "Most recent" )
  	        @tagsBD = Tag.order('updated_at DESC').limit(10)
  	        @tags = Hash.new
            @tagsBD.each do |tag|
                @tags[tag.name] = tag.frequency
            end
  	    elsif (params[:cat] == "Most popular" )
  	        @tagsBD = Tag.order('tags.frequency DESC').limit(10)
  	        @tags = Hash.new
            @tagsBD.each do |tag|
                @tags[tag.name] = tag.frequency
            end
  	    elsif (!params[:related].nil? and !Tag.find(:first, :order => "frequency DESC", :limit => 10, :conditions => ['name = ?', params[:related].strip ]).related.nil? )
  	        @tags = Hash.new
  	        Tag.find(:first, :order => "frequency DESC", :limit => 10, :conditions => ['name = ?', params[:related].strip ]).related.split(";").each do |tag|
                @tags[tag] = Tag.where(:name => tag)[0].frequency
  	        end
  	    else
  	        @tagsBD = Tag.order('frequency DESC').limit(10)
            @tags = Hash.new
           
  	    end
        
        # Tag Cloud
        @max_size = 20; # max font size in pixels
        @min_size = 12; # min font size in pixels
       
        # largest and smallest array values
        @max_qty = @tags.values.max
        @min_qty = @tags.values.min
       
        # find the range of values
        @spread = @max_qty - @min_qty unless @tags.empty?
        
        # we don't want to divide by zero
        if @spread == 0  
            @spread = 1
        end
       
        # set the font-size increment
        @step = (@max_size - @min_size) / (@spread.to_f) 
          
        @out = '<div class="subcategory" id="tagCloud" style="display:block;">'
        @out.concat('<ul>')
        
        @tags.each do |key, value|
            @out.concat('<a ')
            if !Tag.find(:first, :conditions => ['name = ?', key]).related.nil?
                @out.concat('onclick="changeRelated(\'')
                @out.concat(key.to_s)
                @out.concat('\'); document.getElementById(\'category\').selectedIndex = \'Related\';" ')
            end          
            @out.concat('class="draggable" style="cursor: move; font-size:')
            @out.concat((@min_size + ((value - @min_qty) * @step)).to_s) 
            @out.concat(' px; ')
            if !Tag.find(:first, :conditions => ['name = ?', key]).related.nil?
                @out.concat('text-decoration:underline;')
            end
            @out.concat(' ">')           
            @out.concat(key.to_s)
            @out.concat('</a><span style="font-size: ')
            @out.concat((@min_size + ((value - @min_qty) * @step)).to_s)
            @out.concat('px"></span>&nbsp;&nbsp;-&nbsp;&nbsp;')
        end
        @out.concat('</ul></div>')
        
        render :text => @out  	   
  	end
  	
  	def duplicateSectionAjax
  	    @space = Space.find(params[:space_id])
  	    @doc = @space.documents.where(:name => params[:section])[0]
  	    
  	    @out = ''
  	    @out = @doc.content unless @doc.nil?
  	    
  	    @space.documents.create(:name => params[:newSection], :content => @out, :status => "open")
  	    
  	    render :text => @out
  	end
  	
  	def get_group_users
        @space = Space.find(params[:space_id])
        @doc = @space.documents.where(:name => params[:section])[0]
        
        @out = ''
        @out = @doc.content unless @doc.nil?
        
        @space.documents.create(:name => params[:newSection], :content => @out, :status => "open")
        
        render :text => @out
    end
    
    def getGroupUsersFromMyNetwork
        @out = ''
        params[:group].split(",").each do |group|          
            Follower.where(:follower_id => current_user.id, :group => group).each do |follower|
                @out.concat(User.find(follower.followed_id).email)
                @out.concat(',')
            end
        end
        
        render :text => @out
    end
end
