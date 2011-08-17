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

class Activity < ActiveRecord::Base
  belongs_to :user
  
  validates :user_id, :presence => true
  validates :job_id, :presence => true
  
  default_scope :order => 'activities.created_at ASC'
  
  def self.search(user, search)
    if search
      find(:all, :conditions =>['user_id=? and message LIKE ?', user.id, "%#{search}%"])
    else  
      user.activities 
    end
  end
  
  def self.from_jobs_followed_by(user)
    #Those are just the jobs owned (not contributed), need to add the contributed too.
    job_ids = user.jobs.map(&:id).join(", ")
    
    if (job_ids.length > 0)
      where ("job_id IN (#{job_ids})")
    elsif
      []
    end
        
  end  
  
end
