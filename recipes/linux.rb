sensu_gem 'ohai'

### Checks

sensu_check 'disk_usage' do
  #file '/system/check-disk.rb'
  command 'check-disk.rb -w 80 -c 90 -x nfs,tmpfs,fuse'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['linux']
  additional({
    :occurrences => node['monitor']['default_occurrences']
  })
end

sensu_check 'memory' do
  #file '/system/check-mem.rb'
  command 'check-mem.rb -w 15 -c 10'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['linux']
  additional({
    :occurrences => node['monitor']['default_occurrences']
  })
end

sensu_check 'swap' do
#file '/system/check-mem.rb'
  command 'check-mem.rb --swap -w 60 -c 50'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['linux']
  additional({
    :occurrences => node['monitor']['default_occurrences']
  })
end

sensu_check 'load' do
  #file '/system/check-load.rb'
  command 'check-load.rb -w 10,15,25 -c 15,20,30'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['linux']
  additional({
    :occurrences => node['monitor']['default_occurrences']
  })
end

sensu_check "fs_writeable_tmp" do
  command "check-fs-writable.rb -d /tmp"
  handlers ["default"]
  interval node['monitor']['default_interval']
  subscribers ['linux']
  additional({
    :occurrences => node['monitor']['default_occurrences']
  })
end

sensu_check "chef_client" do
  command "check-chef-client.rb"
  handlers ["default"]
  interval node['monitor']['default_interval']
  subscribers ['linux']
  additional({
    :occurrences => node['monitor']['default_occurrences']
  })
end

#sensu_check "chef_client_log" do
#  command "check-log.rb -f /var/log/chef/client.log -q \"FATAL\" -E \"Chef is already running\""
#  handlers ["default"]
#  interval node['monitor']['default_interval']
#  subscribers ['linux']
#  additional({
#    :occurrences => node['monitor']['default_occurrences']
#  })
#end

### Metrics

sensu_check "load_metrics" do
  type "metric"
  command "load-metrics.rb --scheme :::scheme_prefix::::::name:::.load"
  handlers ["metrics"]
  interval node['monitor']['metric_interval']
  subscribers ['linux']
  additional({
    :occurrences => node['monitor']['metric_occurrences']
  })
end

sensu_check "cpu_metrics" do
  type "metric"
  command "cpu-metrics.rb --scheme :::scheme_prefix::::::name:::.cpu"
  handlers ["metrics"]
  interval node['monitor']['metric_interval']
  subscribers ['linux']
  additional({
    :occurrences => node['monitor']['metric_occurrences']
  })
end

sensu_check "memory_metrics" do
  type "metric"
  command "memory-metrics.rb --scheme :::scheme_prefix::::::name:::.memory"
  handlers ["metrics"]
  interval node['monitor']['metric_interval']
  subscribers ['linux']
  additional({
    :occurrences => node['monitor']['metric_occurrences']
  })
end

sensu_check "interface_metrics" do
  type "metric"
  command "interface-metrics.rb --scheme :::scheme_prefix::::::name:::.interface"
  handlers ["metrics"]
  interval node['monitor']['metric_interval']
  subscribers ['linux']
  additional({
    :occurrences => node['monitor']['metric_occurrences']
  })
end

sensu_check "disk_metrics" do
  type "metric"
  command "disk-metrics.rb --scheme :::scheme_prefix::::::name:::.disk"
  handlers ["metrics"]
  interval node['monitor']['metric_interval']
  subscribers ['linux']
  additional({
    :occurrences => node['monitor']['metric_occurrences']
  })
end

sensu_check "disk_usage_metrics" do
  type "metric"
  command "disk-usage-metrics.rb -l --scheme :::scheme_prefix::::::name:::.disk_usage"
  handlers ["metrics"]
  interval node['monitor']['metric_interval']
  subscribers ['linux']
  additional({
    :occurrences => node['monitor']['metric_occurrences']
  })
end
