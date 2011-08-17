#!/usr/bin/ruby

require "document_diff/document_diff"
require "html_diff/html_diff"
require "spam_diff/spam_diff"

size = 10000
step = 10000
while size < 500000
  str = " and " * (size/5)
  strb = ((" and " * 9) + " not ") * (size/50)
  ddiftime = Time.now
  res = DocumentDiff.diff(str, strb, "user")
  ddiftime = Time.now - ddiftime
  htmltime = Time.now
  res = HtmlDiff.diff(str, strb, "user")
  htmltime = Time.now - htmltime
  spamtime = Time.now
  res = SpamDiff.diff(str, strb, "user")
  spamtime = Time.now - spamtime
  fertime = Time.now
  res = Differ.diff_by_word(strb, str).to_s
  fertime = Time.now - fertime
  puts "#{str.size}, #{fertime}, #{(str.size / fertime).round}, D #{ddiftime}, #{(str.size / ddiftime).round}, #{(str.size / (ddiftime - fertime)).round}, H #{htmltime}, #{(str.size / htmltime).round}, #{(str.size / (htmltime - fertime)).round}, S #{spamtime}, #{(str.size / spamtime).round}, #{(str.size / (spamtime - fertime)).round}"
  size += step
end
