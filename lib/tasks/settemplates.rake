desc "This task is called only once t create the Tags"

task :settemplates => :environment do
  if !(Templates.find(:first, :conditions => ['user_id = ?', '0']))
    	Templates.create(:name => 'Custom', :content => 'Section 1,Section 2', :user_id => 0)
    	Templates.create(:name => 'No section', :content => 'Main text', :user_id => 0)
    	Templates.create(:name => 'Market Knowledge', :content => 'Market opportunity & trends,Customer purchase process,Main players,Key competitors,Distributors,Regulations', :user_id => 0)
    	Templates.create(:name => 'Technology', :content => 'State of the Art,Who is doing what,Sites & Publications,Brainstorming', :user_id => 0)
    	Templates.create(:name => 'Feedback', :content => 'Content,Flow,Format,Wording,Tone', :user_id => 0)
    	Templates.create(:name => 'Brainstorming', :content => 'List of ideas,Idea 1,Idea n,Selection criteria,Evaluation,Comments', :user_id => 0)
      Templates.create(:name => 'Problem Solving', :content => 'Alternatives,Related experiences,Evaluation criteria,Alterantive 1,Alternative n,Evaluation,Sources of information', :user_id => 0)
  end
end