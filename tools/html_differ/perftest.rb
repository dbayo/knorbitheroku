#!/usr/bin/ruby

require "nontag_diff"

size = 10000
step = 10000
while size < 500000
  str = " and " * (size/5)
  strb = ((" and " * 9) + " not ") * (size/50)
  time = Time.now
  res = NontagDiff.new(str, strb, "user").differ
  dtime = Time.now - time
  time = Time.now
  res = NontagDiff.new(str, strb, "user").diff
  time = Time.now - time
  puts "#{size}, #{dtime}, #{time}, #{size/time}, #{size / (time - dtime)}"
  size += step
end
