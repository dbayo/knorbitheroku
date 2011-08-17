require 'rubygems'
require 'differ'

#TODO: Improve this by joining sucessive tagging of the same user
#TODO: Check why the . is being set as diff even though it is not (check commented test)

class DocumentDiff
  START_TAG = "\0" #"$"#"\0"
  END_TAG   = "\1" #"%"#"\1"
  #FORMAT_START = %Q{<span style="color: #USER#;">} 
  FORMAT_START = %Q{<span class="#USER#">} #%Q{<span style="color: #{userid};">}
  FORMAT_END = %Q{</span>}
  
  def self.diff(old, new, userid)
    old ||= ""
    new ||= ""
    #DifferFormat.user(userid)
    DifferFormat.settag(START_TAG, END_TAG)
    Differ.format = DifferFormat
    result = Differ.diff_by_word(new, old).to_s
    #puts result
    result = self.clean_in_tags(result)
    result = self.format_to_user(result, userid)
    return result
  end
  
  def self.get_users(str)
    str ||= ""
    regexp = Regexp.new(FORMAT_START.gsub('#USER#', '(.*?)'))
    
    str.scan(regexp).flatten.uniq
  end
  
  def self.clean_in_tags(str)
    #puts str
    res = ""
    inside = false
    in_tag = false
    sensible_zone = false
    str.each_char do |char|
      case char
      when '<'
        raise "< should not have come" if inside
        inside = true
        if in_tag
          res += END_TAG
          if sensible_zone
            in_tag = false
            sensible_zone = false
          end
        end
        res += char
      when '>'
        raise "> should not have come" if !inside
        inside = false
        res += char
        if in_tag 
          res += START_TAG
        end
      when START_TAG
        raise "START_TAG should not have come" if in_tag && (inside || !sensible_zone)  
        in_tag = true
        if !inside && !sensible_zone 
          res += char 
        end
        sensible_zone = false
      when END_TAG
        raise "END_TAG should not have come " if !in_tag
        if inside
          in_tag = false
        else
          sensible_zone = true     
        end
      else
        if sensible_zone == true
          if char != " "
            res += END_TAG #if !inside    
            sensible_zone = false
            in_tag = false
          end
        end
        res += char
      end
    end
    if in_tag && !inside
      res += END_TAG
    end
    #puts res
    return res
  end

  def self.format_to_user(str, userid)
    format_start = FORMAT_START.gsub('#USER#', userid)
    format_end = FORMAT_END
    str.gsub!(START_TAG, format_start)
    str.gsub!(END_TAG, format_end)
    #puts str
    return str
  end  
  
  class DifferFormat
    @@instag = "<INSERTED>"
    @@instagend = "</INSERTED>"
    
    def self.settag(ins, del)
      @@instag = ins
      @@instagend = del
    end
    
    def self.format(change)
      (change.change? && as_change(change)) ||
      (change.delete? && as_delete(change)) ||
      (change.insert? && as_insert(change)) ||
      ''
    end
  
    def self.as_insert(change)
      #%Q{<span style="color: green;">#{change.insert}</span>}
      %Q{#{@@instag}#{change.insert}#{@@instagend}}
    end
  
    def self.as_delete(change)
      #%Q{<span style="color: red;">#{change.delete}</span>}
      #%Q{<<DELETED>>#{change.delete}<</DELETED>>}
      #Nothing will be shown on deletion
      ""
    end
  
    def self.as_change(change)
      as_delete(change) << as_insert(change)
    end
 end
end


#puts DocumentDiff.diff("This is the first string", "And I am the second string", "red")
#puts DocumentDiff.diff("<p>string</p>", "<b>string</b>", "red")
#puts DocumentDiff.diff("<p>string</p>", "I modified the <p>string</p>", "red")
#puts DocumentDiff.diff("<p>string</p>", "I modified the <p> new string</p>", "red")
#puts DocumentDiff.diff("<p>string</p>", "<p class>new string</p>", "red")
#puts DocumentDiff.diff("I am not the <p>string</p>", "And me neither <p>string</p>", "red")
#res =  DocumentDiff.diff("I am not the <p>string</p>", "And me neither <b>string</b>", "red")
#puts res
#puts
#puts DocumentDiff.diff(res,res.gsub("neither", "also neither").gsub("</b>","also </b>"),"green")
