#!/usr/bin/ruby

require "document_diff"

size = 10000
step = 10000
while size < 500000
  str = " and " * (size/5)
  strb = ((" and " * 9) + " not ") * (size/50)
  time = Time.now
  res = DocumentDiff.diff(str, strb, "user")
  time = Time.now - time
  puts "#{size}, #{time}, #{size/time}"
  size += step
end
