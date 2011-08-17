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

class Job < ActiveRecord::Base
  belongs_to :user
  
  validates :name, :presence => true
  validates :user_id, :presence => true
  validates :description, :presence => true	
  
  has_many :contributed, :foreign_key => "job_id",
                         :class_name => "Contribution"
  
  # Activitis table
  has_many :activities, :foreign_key => "job_id",
                         :class_name => "Activity"
   
  default_scope :order => 'jobs.created_at DESC'
  
  def self.search(user, search)
    if search
      where('user_id=? AND ( LOWER(name) LIKE ? or LOWER(description) LIKE ?)', user.id, "%#{search.downcase}%", "%#{search.downcase}%") + 
      joins(:contributed).where('contributions.job_id = jobs.id AND contributions.user_id = ? AND (LOWER(jobs.name) LIKE ? OR LOWER(jobs.description) LIKE ?)' , user.id,"%#{search.downcase}%","%#{search.downcase}%")
    else  
      user.jobs 
    end
  end
  
  def self.close_jobs()
    #Close jobs      
    #update_all ['status = ?', 'closed'], ['date > ?',  4.week.ago]
    Job.where(:status => 'open') do |job| 
      if (job.date != nil)
        if (job.date < job.duration.hour.ago.to_date)
          job.status = 'closed'
          job.save
          
          Invitations.where(:job_id => job.id) do |inv|
              inv.status = 'no accepted'
              inv.save
          end
        end
      end
    end 
  end
  
end
