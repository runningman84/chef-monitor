#
# Cookbook Name:: monitor
# Recipe:: _check_rabbitmq
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

include_recipe 'build-essential::default' unless node['os'] == 'windows'

sensu_gem 'sensu-plugins-rabbitmq' do
  version node['monitor']['sensu_gem_versions']['sensu-plugins-rabbitmq']
end

sensu_check 'rabbitmq_process' do
  command 'check-process.rb -p .*rabbitmq_server -C 1 -u rabbitmq'
  handlers ['default']
  standalone true
  interval node['monitor']['default_interval']
  additional(
    occurrences: node['monitor']['default_occurrences'],
    graphiteStat0012hRate: graphite_url(['perSecond(:::scheme_prefix::::::name:::.rabbitmq.*.*.rate)'], 'from' => '-12hours', 'height' => 300, 'width' => 600),
    graphiteStat0012hCount: graphite_url([':::scheme_prefix::::::name:::.rabbitmq.queue_totals.*.count'], 'from' => '-12hours', 'height' => 200, 'width' => 600),
    graphiteStat0072hRate: graphite_url(['perSecond(:::scheme_prefix::::::name:::.rabbitmq.*.*.rate)'], 'from' => '-72hours', 'height' => 300, 'width' => 600),
    graphiteStat0072hCount: graphite_url([':::scheme_prefix::::::name:::.rabbitmq.queue_totals.*.count'], 'from' => '-72hours', 'height' => 200, 'width' => 600),
    graphiteStat0090dRate: graphite_url(['perSecond(:::scheme_prefix::::::name:::.rabbitmq.*.*.rate)'], 'from' => '-90days', 'height' => 300, 'width' => 600),
    graphiteStat0090dCount: graphite_url([':::scheme_prefix::::::name:::.rabbitmq.queue_totals.*.count'], 'from' => '-90days', 'height' => 200, 'width' => 600),
    refresh: node['monitor']['default_refresh']
  )
  only_if { node['recipes'].include?('monitor::_install_rabbitmq') }
end

# FIX: check broken on newer rabbitmq versions
# sensu_check 'rabbitmq_alive' do
#   command 'check-rabbitmq-alive.rb'
#   handlers ['default']
#   standalone true
#   interval node['monitor']['default_interval']
#   additional(
#     dependencies: ['rabbitmq_process'],
#     occurrences: node['monitor']['default_occurrences'],
#     graphiteStat0012hRate: graphite_url(['perSecond(:::scheme_prefix::::::name:::.rabbitmq.*.*.rate)'], 'from' => '-12hours', 'height' => 300, 'width' => 600),
#     graphiteStat0012hCount: graphite_url([':::scheme_prefix::::::name:::.rabbitmq.queue_totals.*.count'], 'from' => '-12hours', 'height' => 200, 'width' => 600),
#     graphiteStat0072hRate: graphite_url(['perSecond(:::scheme_prefix::::::name:::.rabbitmq.*.*.rate)'], 'from' => '-72hours', 'height' => 300, 'width' => 600),
#     graphiteStat0072hCount: graphite_url([':::scheme_prefix::::::name:::.rabbitmq.queue_totals.*.count'], 'from' => '-72hours', 'height' => 200, 'width' => 600),
#     graphiteStat0090dRate: graphite_url(['perSecond(:::scheme_prefix::::::name:::.rabbitmq.*.*.rate)'], 'from' => '-90days', 'height' => 300, 'width' => 600),
#     graphiteStat0090dCount: graphite_url([':::scheme_prefix::::::name:::.rabbitmq.queue_totals.*.count'], 'from' => '-90days', 'height' => 200, 'width' => 600),
#     refresh: node['monitor']['default_refresh']
#   )
#   only_if { node['recipes'].include?('monitor::_install_rabbitmq') }
# end

sensu_check 'rabbitmq_node-health' do
  command 'check-rabbitmq-node-health.rb'
  handlers ['default']
  standalone true
  interval node['monitor']['default_interval']
  additional(
    dependencies: ['rabbitmq_process'],
    occurrences: node['monitor']['default_occurrences'],
    graphiteStat0012hRate: graphite_url(['perSecond(:::scheme_prefix::::::name:::.rabbitmq.*.*.rate)'], 'from' => '-12hours', 'height' => 300, 'width' => 600),
    graphiteStat0012hCount: graphite_url([':::scheme_prefix::::::name:::.rabbitmq.queue_totals.*.count'], 'from' => '-12hours', 'height' => 200, 'width' => 600),
    graphiteStat0072hRate: graphite_url(['perSecond(:::scheme_prefix::::::name:::.rabbitmq.*.*.rate)'], 'from' => '-72hours', 'height' => 300, 'width' => 600),
    graphiteStat0072hCount: graphite_url([':::scheme_prefix::::::name:::.rabbitmq.queue_totals.*.count'], 'from' => '-72hours', 'height' => 200, 'width' => 600),
    graphiteStat0090dRate: graphite_url(['perSecond(:::scheme_prefix::::::name:::.rabbitmq.*.*.rate)'], 'from' => '-90days', 'height' => 300, 'width' => 600),
    graphiteStat0090dCount: graphite_url([':::scheme_prefix::::::name:::.rabbitmq.queue_totals.*.count'], 'from' => '-90days', 'height' => 200, 'width' => 600),
    refresh: node['monitor']['default_refresh']
  )
  only_if { node['recipes'].include?('monitor::_install_rabbitmq') }
end

# sensu_check 'rabbitmq_queue-drain-time' do
#  command 'check-rabbitmq-queue-drain-time.rb -w 300 -c 3600'
#  handlers ['default']
#  standalone true
#  interval node['monitor']['default_interval']
#  additional(
#    dependencies: ['rabbitmq_process'],
#    occurrences: node['monitor']['default_occurrences']
#  )
# end

sensu_check 'rabbitmq_overview_metrics' do
  type 'metric'
  command "metrics-rabbitmq-overview.rb --scheme :::scheme_prefix::::::name:::.rabbitmq --host #{node['sensu']['rabbitmq']['host']}"
  handlers ['metrics']
  standalone true
  interval node['monitor']['metric_interval']
  additional(
    dependencies: ['rabbitmq_process'],
    occurrences: node['monitor']['metric_occurrences'],
    graphiteStat0012hRate: graphite_url(['perSecond(:::scheme_prefix::::::name:::.rabbitmq.*.*.rate)'], 'from' => '-12hours', 'height' => 300, 'width' => 600),
    graphiteStat0012hCount: graphite_url([':::scheme_prefix::::::name:::.rabbitmq.queue_totals.*.count'], 'from' => '-12hours', 'height' => 200, 'width' => 600),
    graphiteStat0072hRate: graphite_url(['perSecond(:::scheme_prefix::::::name:::.rabbitmq.*.*.rate)'], 'from' => '-72hours', 'height' => 300, 'width' => 600),
    graphiteStat0072hCount: graphite_url([':::scheme_prefix::::::name:::.rabbitmq.queue_totals.*.count'], 'from' => '-72hours', 'height' => 200, 'width' => 600),
    graphiteStat0090dRate: graphite_url(['perSecond(:::scheme_prefix::::::name:::.rabbitmq.*.*.rate)'], 'from' => '-90days', 'height' => 300, 'width' => 600),
    graphiteStat0090dCount: graphite_url([':::scheme_prefix::::::name:::.rabbitmq.queue_totals.*.count'], 'from' => '-90days', 'height' => 200, 'width' => 600),
    refresh: node['monitor']['default_refresh']
  )
  not_if { node['monitor']['metric_disabled'] }
end
