sensu_gem 'ohai'

sensu_check 'disk_usage' do
  #file '/system/check-disk.rb'
  command 'check-disk.rb -w 80 -c 90 -x nfs,tmpfs,fuse'
  handlers ['default']
  interval 30
  subscribers ['linux']
  additional({
    :occurrences => 2
  })
end

sensu_check 'memory' do
  #file '/system/check-mem.rb'
  command 'check-mem.rb -w 15 -c 10'
  handlers ['default']
  interval 30
  subscribers ['linux']
  additional({
    :occurrences => 2
  })
end

sensu_check 'swap' do
#file '/system/check-mem.rb'
  command 'check-mem.rb --swap -w 60 -c 50'
  handlers ['default']
  interval 30
  subscribers ['linux']
  additional({
    :occurrences => 2
  })
end

sensu_check 'load' do
  #file '/system/check-load.rb'
  command 'check-load.rb -w 10,15,25 -c 15,20,30'
  handlers ['default']
  interval 30
  subscribers ['linux']
  additional({
    :occurrences => 2
  })
end

sensu_check "fs_writeable_tmp" do
  command "check-fs-writable.rb -d /tmp"
  handlers ["default"]
  interval 30
  subscribers ['linux']
  additional({
    :occurrences => 2
  })
end

sensu_check "chef_client" do
  command "check-chef-client.rb"
  handlers ["default"]
  interval 30
  subscribers ['linux']
  additional({
    :occurrences => 2
  })
end

sensu_check "load_metrics" do
  type "metric"
  command "load-metrics.rb --scheme :::scheme_prefix::::::name:::.load"
  handlers ["graphite"]
  interval 60
  subscribers ['linux']
end

sensu_check "memory_metrics" do
  type "metric"
  command "memory-metrics.rb --scheme :::scheme_prefix::::::name:::.memory"
  handlers ["graphite"]
  interval 60
  subscribers ['linux']
end

sensu_check "interface_metrics" do
  type "metric"
  command "interface-metrics.rb --scheme :::scheme_prefix::::::name:::.interface"
  handlers ["graphite"]
  interval 60
  subscribers ['linux']
end

sensu_check "disk_metrics" do
  type "metric"
  command "disk-metrics.rb --scheme :::scheme_prefix::::::name:::.disk"
  handlers ["graphite"]
  interval 60
  subscribers ['linux']
end

sensu_check "disk_usage_metrics" do
  type "metric"
  command "disk-usage-metrics.rb -l --scheme :::scheme_prefix::::::name:::.disk_usage"
  handlers ["graphite"]
  interval 60
  subscribers ['linux']
end
