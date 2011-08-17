require 'rubygems'
require 'differ'

#TODO: Improve this by joining sucessive tagging of the same user
#TODO: Check why the . is being set as diff even though it is not (check commented test)

class HtmlDiff
#  DEBUG = true
  START_TAG = "\0"#"$"#"\0"
  END_TAG   = "\1"#"%"#"\1"
  #FORMAT_START = %Q{<span style="color: #USER#;">} 
  FORMAT_START = %Q{<span class="#USER#">} #%Q{<span style="color: #{userid};">}
  FORMAT_END = %Q{</span>}
  
  def self.diff(old, new, userid)
    old ||= ""
    new ||= ""
    #DifferFormat.user(userid)
    DifferFormat.settag(START_TAG, END_TAG)
    Differ.format = DifferFormat
    duration = Time.now()
    result = Differ.diff_by_word(new, old).to_s
    #puts result
    duration = Time.now() - duration
    File.open("timing.log", "a+") do |f|
      f.puts " Differ duration #{duration}"
    end
    #puts result
    duration = Time.now()
    result = self.clean_in_tags(result)
    duration = Time.now() - duration
    File.open("timing.log", "a+") do |f|
      f.puts " Clean in tags (cp)duration #{duration}"
    end
    duration = Time.now()
    result = self.format_to_user(result, userid)
    duration = Time.now() - duration
    File.open("timing.log", "a+") do |f|
      f.puts " Format to user duration #{duration}"
    end
    return result
  end
  
  def self.get_users(str)
    str ||= ""
    regexp = Regexp.new(FORMAT_START.gsub('#USER#', '(.*?)'))
    
    str.scan(regexp).flatten.uniq
  end
  
  def self.clean_in_tags(str)
    #puts str
    res = str + (" " * 1000)
    idstr = 0
    idres = 0
    in_tag = false
    in_diff = false
    diff_exit = false
    ### States
    # in_tag  in_diff  diff_exit state
    # false   false    false     initial
    # true    false    false     tag
    # false   true     false     diff
    # true    true     false     diff_tag
    # false   false    true      diff_exit
    while idstr < str.size
      res += " " * 1000 if idres > res.size - 20
      #puts "Token '#{str[idstr].chr}' state (in_diff = #{in_diff}, in_tag = #{in_tag}, diff_exit #{diff_exit})"
      case str[idstr]
        when '<'[0]
          if in_tag
            raise "Unexpected '<' (in_diff = #{in_diff}, in_tag = #{in_tag}, diff_exit #{diff_exit})"
          end
          if in_diff || diff_exit
            res[idres] = END_TAG[0]
            idres += 1
            diff_exit = false
          end
          res[idres] = str[idstr]
          idres += 1
          idstr += 1
          in_tag = true

        when '>'[0]
          if !in_tag 
            raise "Unexpected '>' (in_diff = #{in_diff}, in_tag = #{in_tag}, diff_exit #{diff_exit})"
          end
          res[idres] = str[idstr]
          idres += 1
          idstr += 1
          if in_diff
            res[idres] = START_TAG[0]
            idres += 1
          end
          in_tag = false
          
        when START_TAG[0]
          if in_diff
            raise "Unexpected START_TAG (in_diff = #{in_diff}, in_tag = #{in_tag}, diff_exit #{diff_exit})"
          end
          if !diff_exit && !in_tag
            res[idres] = str[idstr]
            idres += 1
          end
          diff_exit = false
          idstr += 1
          in_diff = true
          
        when END_TAG[0]
          if !in_diff || diff_exit
            raise "Unexpected END_TAG (in_diff = #{in_diff}, in_tag = #{in_tag}, diff_exit #{diff_exit})"
          end
          if !in_tag
            diff_exit = true
          end
          idstr += 1
          in_diff = false
        when " "[0]
          res[idres] = str[idstr]
          idres += 1
          idstr += 1
        else
          #char
          if diff_exit
            res[idres] = END_TAG[0]
            idres += 1
            diff_exit = false
          end
          res[idres] = str[idstr]
          idres += 1
          idstr += 1
      end  
    end
    if diff_exit == true
      res[idres] = END_TAG[0]
      idres += 1
      diff_exit = false
    end
    #puts "Final state (in_diff = #{in_diff}, in_tag = #{in_tag}, diff_exit #{diff_exit})"     
    return res[0..(idres-1)]
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

#puts HtmlDiff.diff( nil, "\r\n\t\t\t\t<p>This is my very first document using knorbit.</p><p>Lets see if it works</p><h1>A title</h1><p>One part with <i>italic</i></p>\r\n\t\t", "r")
#puts HtmlDiff.diff("This is the first string", "And I am the second string", "r")
#puts DocumentDiff.diff("<p>string</p>", "<b>string</b>", "red")
#puts DocumentDiff.diff("<p>string</p>", "I modified the <p>string</p>", "red")
#puts DocumentDiff.diff("<p>string</p>", "I modified the <p> new string</p>", "red")
#puts DocumentDiff.diff("<p>string</p>", "<p class>new string</p>", "red")
#puts DocumentDiff.diff("I am not the <p>string</p>", "And me neither <p>string</p>", "red")
#res =  DocumentDiff.diff("I am not the <p>string</p>", "And me neither <b>string</b>", "red")
#puts res
#puts
#puts DocumentDiff.diff(res,res.gsub("neither", "also neither").gsub("</b>","also </b>"),"green")

old = %Q{}
new = %Q{<p>This is my very first document using knorbit.</p><p>Lets see if it works</p><h1>A title</h1><p>One part with <i>italic</i></p>}
result = %Q{<span class="user1"></span><p><span class="user1">This is my very first document using knorbit.</span></p><span class="user1"></span><p><span class="user1">Lets see if it works</span></p><span class="user1"></span><h1><span class="user1">A title</span></h1><span class="user1"></span><p><span class="user1">One part with </span><i><span class="user1">italic</span></i><span class="user1"></span></p><span class="user1"></span>}



old = %Q{<span class="user1"></span><p><span class="user1">This is my very first document using knorbit.</span></p><span class="user1"></span><p><span class="user1">Lets see if it works</span></p><span class="user1"></span><h1><span class="user1">A title</span></h1><span class="user1"></span><p><span class="user1">One part with </span><i><span class="user1">italic</span></i><span class="user1"></span></p><span class="user1"></span>}
new = %Q{<span class="user1"></span><p><span class="user1">This is my very second document using knorbit.</span></p><span class="user1"></span><p><span class="user1">Lets see if it works when I modify it<br></span></p><span class="user1"></span><h1><span class="user1">A title</span></h1><span class="user1"></span><p><span class="user1">One part <b>also</b> with </span><i><span class="user1">italic</span></i><span class="user1"></span></p><span class="user1"></span>}
result = %Q{<span class="user1"></span><p><span class="user1">This is my very <span class="user2">second </span>document using knorbit.</span></p><span class="user1"></span><p><span class="user1">Lets see if it works<span class="user2"> when I modify it</span><br><span class="user2"></span></span><span class="user2"></span></p><span class="user2"></span><span class="user1"><span class="user2"></span></span><span class="user2"></span><h1><span class="user2"></span><span class="user1"><span class="user2">A title</span></span></h1><span class="user1"></span><p><span class="user1">One part<span class="user2"> </span><b><span class="user2">also</span></b><span class="user2"> with </span></span><span class="user2"></span><i><span class="user2"></span><span class="user1">italic</span></i><span class="user1"></span></p><span class="user1"></span>}
