sensu_gem 'ohai'

### Checks

sensu_check 'ssh' do
  # file '/system/check-disk.rb'
  command 'check-banner.rb'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['linux'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['default_occurrences']
  )
end

sensu_check 'disk_usage' do
  # file '/system/check-disk.rb'
  command 'check-disk-usage.rb -w 80 -c 90 -x nfs,tmpfs,fuse'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['linux'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['default_occurrences'],
    graphiteStat0012h: graphite_url([':::scheme_prefix::::::name:::.disk_usage.root.used_percentage', ':::scheme_prefix::::::name:::.disk_usage.*.*.used_percentage'], 'from' => '-12hours'),
    graphiteStat0072h: graphite_url([':::scheme_prefix::::::name:::.disk_usage.root.used_percentage', ':::scheme_prefix::::::name:::.disk_usage.*.*.used_percentage'], 'from' => '-72hours'),
    graphiteStat0090d: graphite_url([':::scheme_prefix::::::name:::.disk_usage.root.used_percentage', ':::scheme_prefix::::::name:::.disk_usage.*.*.used_percentage'], 'from' => '-90days')
  )
end

sensu_check 'memory' do
  # file '/system/check-mem.rb'
  command 'check-memory.rb -w 15 -c 10'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['linux'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['default_occurrences'],
    graphiteStat0012h: graphite_url([':::scheme_prefix::::::name:::.memory.free'], 'from' => '-12hours'),
    graphiteStat0072h: graphite_url([':::scheme_prefix::::::name:::.memory.free'], 'from' => '-72hours'),
    graphiteStat0090d: graphite_url([':::scheme_prefix::::::name:::.memory.free'], 'from' => '-90days')
  )
end

sensu_check 'swap' do
  # file '/system/check-mem.rb'
  command 'check-swap.rb -w 60 -c 50'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['linux'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['default_occurrences'],
    graphiteStat0012h: graphite_url([':::scheme_prefix::::::name:::.memory.{swapTotal,swapUsed}'], 'from' => '-12hours'),
    graphiteStat0072h: graphite_url([':::scheme_prefix::::::name:::.memory.{swapTotal,swapUsed}'], 'from' => '-72hours'),
    graphiteStat0090d: graphite_url([':::scheme_prefix::::::name:::.memory.{swapTotal,swapUsed}'], 'from' => '-90days')
  )
end

# graphiteStat12h: graphite_url(["sensu.logstash.eu-central-1a.i-f5fe2348.load.load_avg.*"]),

sensu_check 'load' do
  # file '/system/check-load.rb'
  command 'check-load.rb -p -w 3,2,1 -c 9,6,3'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['linux'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['default_occurrences'],
    graphiteStat0012h: graphite_url([':::scheme_prefix::::::name:::.load.load_avg.*'], 'from' => '-12hours'),
    graphiteStat0072h: graphite_url([':::scheme_prefix::::::name:::.load.load_avg.*'], 'from' => '-72hours'),
    graphiteStat0090d: graphite_url([':::scheme_prefix::::::name:::.load.load_avg.*'], 'from' => '-90days')
  )
end

sensu_check 'fs_writeable_tmp' do
  command 'check-fs-writable.rb -d /tmp'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['linux'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['default_occurrences']
  )
end

### Metrics

sensu_check 'load_metrics' do
  type 'metric'
  command 'metrics-load.rb --scheme :::scheme_prefix::::::name:::.load'
  handlers ['metrics']
  interval node['monitor']['metric_interval']
  subscribers ['linux'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['metric_occurrences'],
    graphiteStat0012h: graphite_url([':::scheme_prefix::::::name:::.load.load_avg.*'], 'from' => '-12hours'),
    graphiteStat0072h: graphite_url([':::scheme_prefix::::::name:::.load.load_avg.*'], 'from' => '-72hours'),
    graphiteStat0090d: graphite_url([':::scheme_prefix::::::name:::.load.load_avg.*'], 'from' => '-90days')
  )
  not_if { node['monitor']['use_system_profile'] }
  not_if { node['monitor']['metric_disabled'] }
end

sensu_check 'cpu_metrics' do
  type 'metric'
  command 'metrics-cpu.rb --scheme :::scheme_prefix::::::name:::.cpu'
  handlers ['metrics']
  interval node['monitor']['metric_interval']
  subscribers ['linux'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['metric_occurrences'],
    graphiteStat0012h: graphite_url(['perSecond(:::scheme_prefix::::::name:::.cpu.total.{user,system,iowait,idle})'], 'from' => '-12hours', 'height' => 300),
    graphiteStat0072h: graphite_url(['perSecond(:::scheme_prefix::::::name:::.cpu.total.{user,system,iowait,idle})'], 'from' => '-72hours', 'height' => 300),
    graphiteStat0090d: graphite_url(['perSecond(:::scheme_prefix::::::name:::.cpu.total.{user,system,iowait,idle})'], 'from' => '-90days', 'height' => 300)
  )
  not_if { node['monitor']['use_system_profile'] }
  not_if { node['monitor']['metric_disabled'] }
end

sensu_check 'memory_metrics' do
  type 'metric'
  command 'metrics-memory.rb --scheme :::scheme_prefix::::::name:::.memory'
  handlers ['metrics']
  interval node['monitor']['metric_interval']
  subscribers ['linux'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['metric_occurrences'],
    graphiteStat0012h: graphite_url([':::scheme_prefix::::::name:::.memory.free'], 'from' => '-12hours'),
    graphiteStat0072h: graphite_url([':::scheme_prefix::::::name:::.memory.free'], 'from' => '-72hours'),
    graphiteStat0090d: graphite_url([':::scheme_prefix::::::name:::.memory.free'], 'from' => '-90days')
  )
  not_if { node['monitor']['use_system_profile'] }
  not_if { node['monitor']['metric_disabled'] }
end

sensu_check 'interface_metrics' do
  type 'metric'
  command 'metrics-interface.rb --scheme :::scheme_prefix::::::name:::.interface'
  handlers ['metrics']
  interval node['monitor']['metric_interval']
  subscribers ['linux'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['metric_occurrences'],
    graphiteStat0012h: graphite_url(['perSecond(:::scheme_prefix::::::name:::.interface.*.{rxBytes,txBytes})'], 'from' => '-12hours'),
    graphiteStat0072h: graphite_url(['perSecond(:::scheme_prefix::::::name:::.interface.*.{rxBytes,txBytes})'], 'from' => '-72hours'),
    graphiteStat0090d: graphite_url(['perSecond(:::scheme_prefix::::::name:::.interface.*.{rxBytes,txBytes})'], 'from' => '-90days')
  )
  not_if { node['monitor']['use_system_profile'] }
  not_if { node['monitor']['metric_disabled'] }
end

sensu_check 'disk_metrics' do
  type 'metric'
  command 'metrics-disk.rb --scheme :::scheme_prefix::::::name:::.disk'
  handlers ['metrics']
  interval node['monitor']['metric_interval']
  subscribers ['linux'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['metric_occurrences'],
    graphiteStat0012h: graphite_url(['perSecond(:::scheme_prefix::::::name:::.disk.*.{reads,writes})'], 'from' => '-12hours', 'height' => 300),
    graphiteStat0072h: graphite_url(['perSecond(:::scheme_prefix::::::name:::.disk.*.{reads,writes})'], 'from' => '-72hours', 'height' => 300),
    graphiteStat0090d: graphite_url(['perSecond(:::scheme_prefix::::::name:::.disk.*.{reads,writes})'], 'from' => '-90days', 'height' => 300)
  )
  not_if { node['monitor']['metric_disabled'] }
end

sensu_check 'disk_usage_metrics' do
  type 'metric'
  command 'metrics-disk-usage.rb -l --scheme :::scheme_prefix::::::name:::.disk_usage'
  handlers ['metrics']
  interval node['monitor']['metric_interval']
  subscribers ['linux'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['metric_occurrences'],
    graphiteStat0012h: graphite_url([':::scheme_prefix::::::name:::.disk_usage.root.used_percentage', ':::scheme_prefix::::::name:::.disk_usage.*.*.used_percentage'], 'from' => '-12hours'),
    graphiteStat0072h: graphite_url([':::scheme_prefix::::::name:::.disk_usage.root.used_percentage', ':::scheme_prefix::::::name:::.disk_usage.*.*.used_percentage'], 'from' => '-72hours'),
    graphiteStat0090d: graphite_url([':::scheme_prefix::::::name:::.disk_usage.root.used_percentage', ':::scheme_prefix::::::name:::.disk_usage.*.*.used_percentage'], 'from' => '-90days')
  )
  not_if { node['monitor']['metric_disabled'] }
end
