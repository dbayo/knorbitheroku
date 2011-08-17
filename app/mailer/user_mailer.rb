class UserMailer < ActionMailer::Base

	def registration_confirmation(jobname, wiki,user,sendto)
    @user = user
    @wiki = wiki
    @jobname = jobname
    mail(:from => "#{user.name} <#{user.email}>", :to => sendto, :subject => "knOrbit - Invitation")  
  end 
  
  def nonorbituser(job, user, invitation, sendto)
    @user = user
    @job = job
    @invitation = invitation
    attachments.inline['blueline.jpg'] = File.read(File.dirname(__FILE__) + '/../../public/images/email/blueline.jpg')
    attachments.inline['accept.jpg'] = File.read(File.dirname(__FILE__) + '/../../public/images/email/acceptbutton.jpg')   
    mail(:from => "#{user.name} <#{user.email}>", :to => sendto, :subject => "Can you help me with this topic?")  
  end 
  
  def orbituser(job, user, invitation, sendto)
    @user = user
    @job = job
    @invitation = invitation
    @sendto = sendto
    attachments.inline['blueline.jpg'] =  File.read(File.dirname(__FILE__) + '/../../public/images/email/blueline.jpg')
    attachments.inline['accept.jpg'] = File.read(File.dirname(__FILE__) + '/../../public/images/email/acceptbutton.jpg') 
    mail(:from => "#{user.name} <#{user.email}>", :to => @sendto.email, :subject => "You have been selected for a new Orbit!")  
  end
end
