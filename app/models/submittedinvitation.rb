class Submittedinvitation < ActiveRecord::Base
    has_one :user, :class_name => "User",
                   :foreign_key => "to_email",
                   :dependent => :destroy
    belongs_to :job
    
    def self.expired_submittedinvitations()
        #Cancel the expired invitations   
        #update_all ['status = ?', 'closed'], ['date > ?',  4.week.ago]
        Submittedinvitation.all do |invitation|
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
