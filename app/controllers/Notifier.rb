class Notifier < ActionMailer::Base
  default :from => "david.bayo.nieto@gmail.com"

  # Send reset password notification to user.
  def   password_reset_mail(user)
    subject    "Password Reset Instructions"
    from        "sender_email_id@test.com"
    recipients  user
    content_type "text/html"
    sent_on     Time.now
    body        "RESET your Password"
  end

	def send_email
		mail(:to => report.user.email,  :subject => "Welcome to Gauravs Site")
	end

end
