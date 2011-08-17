desc "This task is called only once t create the Tags"
require 'csv'

task :settags => :environment do
    if !(Tag.find(:all)).any?
        CSV.foreach(File.dirname(__FILE__) + "/tags.csv","\r") do |row|
            row[0].split(";").each do |tag|
                @tag = Tag.where(:name => tag)[0]
                if @tag.nil?
                    @arraynewtags = []            
                    row[0].split(";").each do |newtag|
                        if newtag != tag and newtag != ''
                            @arraynewtags << newtag
                        end
                    end
                    Tag.create(:name => tag, :frequency => 0, :related => @arraynewtags.join(";")) unless @arraynewtags.empty?        
                else              
                    @arraynewtags = row[0].split(";")       
                    row[0].split(";").each do |newtag|
                        if @tag.related.split(";").index(newtag.strip).nil? and newtag != @tag.name and newtag != ''
                            @arraynewtags << newtag.strip
                        end
                        if newtag == @tag.name
                        end
                    end
                    @tag.update_attributes(:related => @arraynewtags.join(";"))
                end
            end
        end
        Tag.find(:all).each do |tag|
            @related = tag.related.split(";").uniq         
            if !@related.delete(tag.name).nil?       
                tag.update_attributes(:related => @related.join(";"))
            end
        end
    end
end