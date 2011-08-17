desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  if Time.now.hour % 8 == 0 # run every four hours
    puts "Updating jobs..."
        Job.close_jobs
    puts "done."
    
    puts "Updating invitations..."
        Invitations.expired_invitations
    puts "done."
    
    puts "Updating submitted invitations..."
        Submittedinvitation.expired_submittedinvitations
    puts "done."
  end

  #if Time.now.hour == 0 # run at midnight
  #  User.send_reminders
  #end
  
  #This runs every time just for testing
  puts "Updating jobs..."
      Job.close_jobs
  puts "done."
  
  puts "Updating invitations..."
      Invitations.expired_invitations
  puts "done."
  
  puts "Updating submitted invitations..."
      Submittedinvitation.expired_submittedinvitations
  puts "done."
end