#
# Cookbook Name:: monitor
# Recipe:: _check_windows
#
# Copyright 2013, Sean Porter Consulting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

sensu_gem 'ohai'

### Checks

sensu_check 'rdp' do
  command 'check-windows-service.rb.bat -s TermService'
  # command 'check-windows-service.ps1 TermService'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['os:windows'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['default_occurrences'],
    refresh: node['monitor']['default_refresh']
  )
end

sensu_check 'winrm' do
  command 'check-windows-service.rb.bat -s WinRM'
  # command 'check-windows-service.ps1 WinRM'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['os:windows'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['default_occurrences'],
    refresh: node['monitor']['default_refresh']
  )
end

sensu_check 'wmi' do
  command 'check-windows-service.rb.bat -s Winmgmt'
  # command 'check-windows-service.ps1 Winmgmt'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['os:windows'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['default_occurrences'],
    refresh: node['monitor']['default_refresh']
  )
end

sensu_check 'task_scheduler' do
  command 'check-windows-service.rb.bat -s Schedule'
  # command 'check-windows-service.ps1 Schedule'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['os:windows'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['default_occurrences'],
    refresh: node['monitor']['default_refresh']
  )
end

sensu_check 'disk_usage' do
  command 'check-windows-disk.rb.bat -w 80 -c 90'
  # command 'check-windows-disk.ps1 80 90'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['os:windows'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['default_occurrences'],
    graphiteStat0012h: graphite_url([':::scheme_prefix::::::name:::.disk_usage.root.used_percentage', ':::scheme_prefix::::::name:::.disk_usage.*.*.used_percentage'], 'from' => '-12hours'),
    graphiteStat0072h: graphite_url([':::scheme_prefix::::::name:::.disk_usage.root.used_percentage', ':::scheme_prefix::::::name:::.disk_usage.*.*.used_percentage'], 'from' => '-72hours'),
    graphiteStat0090d: graphite_url([':::scheme_prefix::::::name:::.disk_usage.root.used_percentage', ':::scheme_prefix::::::name:::.disk_usage.*.*.used_percentage'], 'from' => '-90days'),
    refresh: node['monitor']['default_refresh']
  )
end

sensu_check 'memory' do
  command 'check-windows-ram.rb.bat -w 85 -c 90'
  # command 'check-windows-ram.ps1 85 90'
  handlers ['default']
  interval node['monitor']['default_interval']
  subscribers ['os:windows'] unless node['monitor']['standalone_mode']
  standalone true if node['monitor']['standalone_mode']
  additional(
    occurrences: node['monitor']['default_occurrences'],
    graphiteStat0012h: graphite_url([':::scheme_prefix::::::name:::.memory.free'], 'from' => '-12hours'),
    graphiteStat0072h: graphite_url([':::scheme_prefix::::::name:::.memory.free'], 'from' => '-72hours'),
    graphiteStat0090d: graphite_url([':::scheme_prefix::::::name:::.memory.free'], 'from' => '-90days'),
    refresh: node['monitor']['default_refresh']
  )
end

### Metrics

if node['monitor']['metric_disabled'] != true

  sensu_check 'cpu_metrics' do
    type 'metric'
    command 'metric-windows-cpu-load.rb.bat --scheme :::scheme_prefix::::::name:::.cpu'
    # command 'metric-windows-cpu-load.ps1'
    handlers ['metrics']
    interval node['monitor']['metric_interval']
    subscribers ['os:windows'] unless node['monitor']['standalone_mode']
    standalone true if node['monitor']['standalone_mode']
    additional(
      occurrences: node['monitor']['metric_occurrences'],
      graphiteStat0012h: graphite_url(['perSecond(:::scheme_prefix::::::name:::.cpu.total.{user,system,iowait,idle})'], 'from' => '-12hours', 'height' => 300),
      graphiteStat0072h: graphite_url(['perSecond(:::scheme_prefix::::::name:::.cpu.total.{user,system,iowait,idle})'], 'from' => '-72hours', 'height' => 300),
      graphiteStat0090d: graphite_url(['perSecond(:::scheme_prefix::::::name:::.cpu.total.{user,system,iowait,idle})'], 'from' => '-90days', 'height' => 300),
      refresh: node['monitor']['default_refresh']
    )
  end

  sensu_check 'memory_metrics' do
    type 'metric'
    command 'metric-windows-ram-usage.rb.bat --scheme :::scheme_prefix::::::name:::.memory'
    # command 'metric-windows-ram-usage.ps1'
    handlers ['metrics']
    interval node['monitor']['metric_interval']
    subscribers ['os:windows'] unless node['monitor']['standalone_mode']
    standalone true if node['monitor']['standalone_mode']
    additional(
      occurrences: node['monitor']['metric_occurrences'],
      graphiteStat0012h: graphite_url([':::scheme_prefix::::::name:::.memory.free'], 'from' => '-12hours'),
      graphiteStat0072h: graphite_url([':::scheme_prefix::::::name:::.memory.free'], 'from' => '-72hours'),
      graphiteStat0090d: graphite_url([':::scheme_prefix::::::name:::.memory.free'], 'from' => '-90days'),
      refresh: node['monitor']['default_refresh']
    )
  end

  sensu_check 'interface_metrics' do
    type 'metric'
    command 'metric-windows-network.rb.bat --scheme :::scheme_prefix::::::name:::.interface'
    # command 'metric-windows-network.ps1'
    handlers ['metrics']
    interval node['monitor']['metric_interval']
    subscribers ['os:windows'] unless node['monitor']['standalone_mode']
    standalone true if node['monitor']['standalone_mode']
    additional(
      occurrences: node['monitor']['metric_occurrences'],
      graphiteStat0012h: graphite_url(['perSecond(:::scheme_prefix::::::name:::.interface.*.{rxBytes,txBytes})'], 'from' => '-12hours'),
      graphiteStat0072h: graphite_url(['perSecond(:::scheme_prefix::::::name:::.interface.*.{rxBytes,txBytes})'], 'from' => '-72hours'),
      graphiteStat0090d: graphite_url(['perSecond(:::scheme_prefix::::::name:::.interface.*.{rxBytes,txBytes})'], 'from' => '-90days'),
      refresh: node['monitor']['default_refresh']
    )
  end

  sensu_check 'disk_usage_metrics' do
    type 'metric'
    command 'metric-windows-disk-usage.rb.bat --scheme :::scheme_prefix::::::name:::.disk_usage'
    # command 'metric-windows-disk-usage.ps1'
    handlers ['metrics']
    interval node['monitor']['metric_interval']
    subscribers ['os:windows'] unless node['monitor']['standalone_mode']
    standalone true if node['monitor']['standalone_mode']
    additional(
      occurrences: node['monitor']['metric_occurrences'],
      graphiteStat0012h: graphite_url([':::scheme_prefix::::::name:::.disk_usage.root.used_percentage', ':::scheme_prefix::::::name:::.disk_usage.*.*.used_percentage'], 'from' => '-12hours'),
      graphiteStat0072h: graphite_url([':::scheme_prefix::::::name:::.disk_usage.root.used_percentage', ':::scheme_prefix::::::name:::.disk_usage.*.*.used_percentage'], 'from' => '-72hours'),
      graphiteStat0090d: graphite_url([':::scheme_prefix::::::name:::.disk_usage.root.used_percentage', ':::scheme_prefix::::::name:::.disk_usage.*.*.used_percentage'], 'from' => '-90days'),
      refresh: node['monitor']['default_refresh']
    )
  end

end
