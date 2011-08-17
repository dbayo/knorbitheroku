require 'rubygems'
require 'differ'


class HtmlDiffer
  SAFE_TAG = "\2\r"#"\r\n"#"#\n" 
  START_TAG = "\0"#"$"#"\0"
  END_TAG   = "\1"#"%"#"\1"
  FORMAT_START = %Q{<span class="user#USER#">}
  FORMAT_END = %Q{</span>}
  
  def self.diff(previous, actual, user, options = {})
    previous ||= ""
    actual ||= ""
    
    #Take out tags
    prev_plain, prev_tags = self.take_tags(previous)
    act_plain, act_tags = self.take_tags(actual)

    #Add fake separation between words that were only tag separated
    prev_fake = self.add_separation(prev_plain, prev_tags)
    act_fake = self.add_separation(act_plain, act_tags)

    #Using differ
    #difference = self.differ(prev_plain, act_plain)
    difference_fake = self.differ(prev_fake, act_fake)
    
    #Take fake separations out of difference
    difference = self.take_separation(difference_fake)

    #Take out difference tags
    new_actplain, new_tags = self.take_diffs(difference)
    
    #At this point the new and old actual strings should be the same
#    if new_actplain != act_plain
#      raise "Strings should be the same '#{act_plain}' and '#{new_actplain}'"
#    end

    #Joining tags
    joinned_tags = []
    if act_tags.size == 0
      joinned_tags = new_tags
    else
      if new_tags.size == 0
        joinned_tags = act_tags
      else
        actid = 0
        newid = 0
        while(actid < act_tags.size)
          while(newid < new_tags.size && act_tags[actid][:pos] > new_tags[newid][:pos])
            joinned_tags << new_tags[newid]
            newid += 1
          end
          joinned_tags << act_tags[actid]
          actid += 1      
        end
      end
    end
#    puts joinned_tags.inspect


    #Sanitize tags
    sane_tags = []
    inspan = false
    innew = false
    
    #stage   inspan innew
    #initial false  false
    #span    true   false
    #new     false  true
    #spannew true   true

    span_open = ""
    span_close = FORMAT_END
    new_start = FORMAT_START.gsub('#USER#', user)
    new_end = FORMAT_END
    
    joinned_tags.each do |tag|
      case tag[:type]
        when :tag
          if innew
            if sane_tags[sane_tags.size - 1][:pos] == tag[:pos] && sane_tags[sane_tags.size - 1][:type] == :new_open  
              #If openned at same position, better is to take out the open
              sane_tags.delete_at(sane_tags.size - 1)
            else
              #Put a proper end
              sane_tags << { :pos => tag[:pos], :type => :new_close, :tag => new_end }
            end
            sane_tags << tag
            sane_tags << { :pos => tag[:pos], :type => :new_open, :tag => new_start }
          else
            if inspan
              sane_tags << { :pos => tag[:pos], :type => :userspan_close, :tag => span_close }
              sane_tags << tag
              sane_tags << { :pos => tag[:pos], :type => :userspan_open, :tag => span_open }
            else
              sane_tags << tag
            end
          end
        when :userspan_open
          if inspan
            raise "Enter in userspan when already in"
          end
          if !innew 
            sane_tags << tag
          end
          span_open = tag[:tag]
          inspan = true
        when :userspan_close
          if !inspan
            raise "Leave userspan when already out"
          end
          if !innew 
            sane_tags << tag
          end
          inspan = false
        when :new_open
          if innew
            raise "Enter in new when already in"
          end
          if inspan 
            sane_tags << { :pos => tag[:pos], :type => :userspan_close, :tag => span_close }
          end
          tag[:tag] = new_start
          sane_tags << tag
          innew = true
        when :new_close
          if !innew
            raise "Leave new when already out"
          end
          if sane_tags[sane_tags.size - 1][:pos] == tag[:pos] && sane_tags[sane_tags.size - 1][:type] == :new_open  
              #If openned at same position, better is to take out the open
              sane_tags.delete_at(sane_tags.size - 1)
          else
            #Put a proper user end
            tag[:tag] = new_end
            sane_tags << tag
          end
          if inspan 
            sane_tags << { :pos => tag[:pos], :type => :userspan_open, :tag => span_open }
          end
          innew = false
      end
    end
    if innew
      if sane_tags[sane_tags.size - 1][:pos] == new_actplain.size && sane_tags[sane_tags.size - 1][:type] == :new_open  
        #If openned at same position, better is to take out the open
        sane_tags.delete_at(sane_tags.size - 1)
      else
        #Put a proper end
        sane_tags << { :pos => new_actplain.size, :type => :new_close, :tag => new_end }
      end
    end
    
#    sane_tags.each do |tag|
#      puts "---TAG #{tag[:pos]} #{tag[:type]} '#{tag[:tag]}'"
#    end
    
    #Put tags back and return
    return HtmlDiffer.put_tags(new_actplain, sane_tags)
  end
 
  private
  def self.differ(previous, actual)
    DifferFormat.settag(START_TAG, END_TAG)
    Differ.format = DifferFormat
    Differ.diff_by_word(actual, previous).to_s
  end
  
  def self.take_diffs(str)
    taglist = []
    result = ""
    res = str.split(/([#{START_TAG}#{END_TAG}])/)
    res.each do |tag|
      case tag[0]
        when START_TAG[0]
          taglist << {:pos => result.size, :type => :new_open, :tag => tag}
        when END_TAG[0]
          taglist << {:pos => result.size, :type => :new_close, :tag => tag}
        else
          result += tag
      end
    end
    return result, taglist
  end
  
  def self.take_tags(html)
    taglist = []
    result = ""
    
    res = html.split(/(<.*?>)/)
    userspan = false
    res.each do |tag|
      if tag[0] == "<"[0]
        tagelement = {:pos => result.size, :tag => tag}
        case tag
          when /<span/
            if tag =~ /<span class="user(.*)"/ 
              tagelement[:type] = :userspan_open
              tagelement[:user] = $1
              userspan = true
            else
              tagelement[:type] = :tag #span open
            end
          when /<\/span>/
            if userspan == true
              tagelement[:type] = :userspan_close
              userspan = false
            else
              tagelement[:type] = :tag #span close
            end
          else
            tagelement[:type] = :tag
        end
#        puts "Adding tag type '#{tagelement[:type]}' at #{tagelement[:pos]} tag:'#{tagelement[:tag]}' #{tagelement[:user]}"
        taglist << tagelement
      else
        result += tag
      end
    end
    
    return result, taglist
  end
  
  def self.put_tags(plain, tags)
    incr = 0
    tags.each do |tag|
      pos = tag[:pos] + incr
#      puts "Adding tag '#{tag[:tag]}' at position #{pos} / #{plain.size}"
      plain = plain[0,pos] + tag[:tag] + plain[pos..plain.size]
      incr += tag[:tag].size
#      puts "Plain is now '#{plain}'"
    end
    return plain
  end
  
  def self.add_separation(str, tags)
    return str if tags.size == 0
    lastid = -1
    diff = 0
    tags.each do |tag|
      if tag[:pos] > lastid
        lastid = tag[:pos]
        pos = tag[:pos] + diff
        str = str[0,pos] + SAFE_TAG + str[pos..str.size]
        diff += SAFE_TAG.size
      end
    end
    return str
  end
  
  def self.take_separation(str)
    str.gsub(SAFE_TAG, "")
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

#    old = %Q{<p>Tag<i>separating</i>words gives a problem</p>}
#    new = %Q{<p>Tag<i>separating two</i>words gives a problem</p>}
#puts HtmlDiffer.diff(old, new, "2")
