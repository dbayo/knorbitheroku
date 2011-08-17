ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {  
  :address => "smtp.gmail.com",  
  :port => "587",  
  :domain => "midominio.com",  
  :user_name => "infoknorbit",  
  :password => "knorbit2011",  
  :authentication => "plain",  
  :enable_starttls_auto => true  
}
