#!/usr/bin/ruby

require "html_differ"
require "test/unit"

class DocumentTest < Test::Unit::TestCase
  
  def perform_test(ori,des,exp,user)
    result = HtmlDiffer.diff(ori, des, user)
#    puts result.to_s
    assert_equal(exp, result.to_s)
    return result.to_s
  end
 
  def test_equal
    str1 = %Q{<p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p>}
    str2 = str1.dup
    perform_test(str1, str2, str2, "1")
  end
  
  def test_addword
    str1 = %Q{<p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p>}
    str2 = %Q{<p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential of the tool.</p>}
    expected = %Q{<p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential<span class="user1"> of the tool</span>.</p>}
    perform_test(str1,str2,expected, "1")
  end
  
  def test_delword
    str1 = %Q{<p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p>}
    str2 = %Q{<p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential of the tool.</p>}
    expected = str1.dup
    perform_test(str2,str1,expected,"1")
  end
 
  def test_subssentence
    str1 = %Q{<p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p>}
    str2 = %Q{<p>Second simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p>}
    expected = %Q{<p><span class="user1">Second</span> simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p>}
    perform_test(str1,str2,expected,"1")
  end
  
#  def test_complex
#    str1 = %Q{
#<p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h2>Sub section</h2><p>Another paragraph.<br></p>
#}
#    str2 =  %Q{
#
#<p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h2>New section</h2><p>Another different paragraph.</p><h3>Just adding another section<br></h3>
#
#}
#    expected = %Q{<span class="auser">\n\n</span><p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h2><span class="auser">New </span>section</h2><p>Another <span class="auser">different </span>paragraph.</p><span class="auser"><h3>Just adding another section<br></h3>\n</span>\n}
#    perform_test(str1,str2,expected, "auser")
#  end
 
  def test_changetag
    str1 = %Q{<p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h2>Sub section</h2><p>Another paragraph.<br></p>}
    str2 = %Q{<p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h3>Sub section</h3><p>Another paragraph.<br></p>}
    expected = str2.dup
    perform_test(str1,str2,expected,"1")
  end
  
  def test_doc
    str1 = %Q{<html><body><p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h2>Sub section</h2><p>Another paragraph.<br></p></body></html>}
    str2 = %Q{<html><body><p>Second simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h2>Sub section</h2><p>Another paragraph.<br></p></body></html>}
    expected = %Q{<html><body><p><span class="user1">Second</span> simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h2>Sub section</h2><p>Another paragraph.<br></p></body></html>}
    res = perform_test(str1,str2,expected,"1")
    #puts "RESULT"
    #puts res
  end
  
  def test_multiuser
    str1 = %Q{<html><body><p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h2>Sub section</h2><p>Another paragraph.<br></p></body></html>}
    str2 = %Q{<html><body><p>Second simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h2>Sub section</h2><p>Another paragraph.<br></p></body></html>}
    expected = %Q{<html><body><p><span class="user1">Second</span> simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h2>Sub section</h2><p>Another paragraph.<br></p></body></html>}
    res = perform_test(str1,str2,expected,"1")
    str3 = res.dup
    str3.gsub!("simple", "not so simple")
    expected.gsub!("simple", "<span class=\"user2\">not so </span>simple")
    res = perform_test(res, str3, expected, "2")
    #puts "RESULT"
    #puts res
    #users = SpamDiff.get_users(res)
    #assert_equal(["auser", "buser"], users)
  end
  
  def test_enter
    str1 = "\n\nOne simple string\n\n"
    str2 = "\n\n\n\nOne simple string\n\n\n\n"
    expected = %Q{<span class="user1">\n\n\n\n</span>One simple string<span class="user1">\n\n\n\n</span>}
    perform_test(str1,str2,expected,"1")
  end
  
  def test_others
    old = %Q{}
    new = %Q{<p>This is the second testing document<br></p>}
    result = %Q{<p><span class="user2">This is the second testing document</span><br></p>}
    perform_test(old,new,result,"2")
  end

  def test_adjacentwords
    old = %Q{<p>Tag<i>separating</i>words gives a problem</p>}
    new = %Q{<p>Tag<i>separating two</i>words gives a problem</p>}
    result = %Q{<p>Tag<i>separating<span class="user2"> two</span></i>words gives a problem</p>}
    perform_test(old,new,result,"2")
  end
end

