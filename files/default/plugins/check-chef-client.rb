#!/usr/bin/env ruby
#

procs = `ps aux`
running = false
procs.each_line do |proc|
  running = true if proc.include?('chef-client')
end
if running
  puts 'OK - Chef client daemon is running'
  exit 0
else
  puts 'WARNING - Chef client daemon is NOT running'
  exit 1
end