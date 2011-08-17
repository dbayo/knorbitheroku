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

class Invitations < ActiveRecord::Base
    has_one :user, :class_name => "User",
                   :foreign_key => "to_email",
                   :dependent => :destroy
    belongs_to :job
    
    def self.expired_invitations()
        #Cancel the expired invitations   
        #update_all ['status = ?', 'closed'], ['date > ?',  4.week.ago]
        Invitations.all do |invitation|
            if !invitation.job.date.nil?
                @duration_job = invitation.job.duration / 24
                if (@duration_job == 21 or @duration_job == 28)
                    @date_stop_invitations = invitation.job.date - 7
                else
                    @date_stop_invitations = invitation.job.date - 2
                end
                
                if Time.now >= @date_stop_invitations
                    invitation.status = 'expired'
                    invitation.save
                end
            end
        end 
    end
end
