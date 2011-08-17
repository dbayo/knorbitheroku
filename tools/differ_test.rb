require "test/unit"
require "rubygems"
require 'differ'


class DifferTest < Test::Unit::TestCase
  def test_tag
    Differ.format = DifferFormat
    old = "This is a tag test"
    new = "This is <br> a tag test"
    expected = "This is$ <br> #a tag test"
    result = Differ.diff_by_word(new, old).to_s
    assert_equal(expected, result)
  end

  def test_tag_with_tags
    Differ.format = DifferFormat
    old = "This is <i> a tag</i> test"
    new = "This is <br> <i> a tag</i> test"
    result = Differ.diff_by_word(new, old).to_s
    assert_equal(new, result)
  end
  
  def test_tag_with_tags
    Differ.format = DifferFormat
    old = %Q{<p>First simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h2>Sub section</h2><p>Another paragraph.<br></p>}
    new = %Q{<p>First <br> simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h2>Sub section</h2><p>Another paragraph.<br></p>}
    expected = %Q{<p>First$ <br> #simple <i>paragraph</i> on which I try to <b>test</b> the potential.</p><h2>Sub section</h2><p>Another paragraph.<br></p>}
    result = Differ.diff_by_word(new, old).to_s
    assert_equal(expected, result)
  end

  class DifferFormat
    @@instag = "$"
    @@instagend = "#"
    
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
