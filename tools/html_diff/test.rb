#!/usr/bin/ruby

require "html_diff"
require "test/unit"

class DocumentTest < Test::Unit::TestCase
  
  def perform_test(ori,des,exp,user)
    result = HtmlDiff.diff(ori, des,user)
#    puts result.to_s
    assert_equal(exp, result.to_s)
    return result.to_s
  end
 
  def test_changetag
    str1 = %Q{<p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h2>Sub section</h2><p>Another paragraph.<br></p>}
    str2 = %Q{<p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h3>Sub section</h3><p>Another paragraph.<br></p>}
    expected = str2.dup
    perform_test(str1,str2,expected,"auser")
  end
  

end