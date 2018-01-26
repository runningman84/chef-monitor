#
# Cookbook Name:: monitor
# Recipe:: _check_redis
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

sensu_gem 'sensu-plugins-redis' do
  version node['monitor']['sensu_gem_versions']['sensu-plugins-redis']
end

sensu_check 'redis_process' do
  command 'check-process.rb -p redis-server -w 2 -c 3 -C 1'
  handlers ['default']
  standalone true
  interval node['monitor']['default_interval']
  additional(
    occurrences: node['monitor']['default_occurrences'],
    graphiteStat0012hCons: graphite_url([':::scheme_prefix::::::name:::.redis.{blocked_clients,connected_clients,connected_slaves}'], 'from' => '-12hours'),
    graphiteStat0072hCons: graphite_url([':::scheme_prefix::::::name:::.redis.{blocked_clients,connected_clients,connected_slaves}'], 'from' => '-72hours'),
    graphiteStat0090dCons: graphite_url([':::scheme_prefix::::::name:::.redis.{blocked_clients,connected_clients,connected_slaves}'], 'from' => '-90days'),
    graphiteStat0012hHits: graphite_url(['perSecond(:::scheme_prefix::::::name:::.redis.{keyspace_hits,keyspace_misses})'], 'from' => '-12hours'),
    graphiteStat0072hHits: graphite_url(['perSecond(:::scheme_prefix::::::name:::.redis.{keyspace_hits,keyspace_misses})'], 'from' => '-72hours'),
    graphiteStat0090dHits: graphite_url(['perSecond(:::scheme_prefix::::::name:::.redis.{keyspace_hits,keyspace_misses})'], 'from' => '-90days'),
    graphiteStat0012hMem: graphite_url([':::scheme_prefix::::::name:::.redis.used_memory'], 'from' => '-12hours'),
    graphiteStat0072hMem: graphite_url([':::scheme_prefix::::::name:::.redis.used_memory'], 'from' => '-72hours'),
    graphiteStat0090dMem: graphite_url([':::scheme_prefix::::::name:::.redis.used_memory'], 'from' => '-90days'),
    refresh: node['monitor']['default_refresh']
  )
  only_if { node['recipes'].include?('monitor::_install_redis') }
end

sensu_check 'redis_metrics' do
  type 'metric'
  command "metrics-redis-graphite.rb --scheme :::scheme_prefix::::::name:::.redis --host #{node['sensu']['redis']['host']}"
  handlers ['metrics']
  standalone true
  interval node['monitor']['metric_interval']
  additional(
    dependencies: ['redis_process'],
    occurrences: node['monitor']['metric_occurrences'],
    graphiteStat0012hCons: graphite_url([':::scheme_prefix::::::name:::.redis.{blocked_clients,connected_clients,connected_slaves}'], 'from' => '-12hours'),
    graphiteStat0072hCons: graphite_url([':::scheme_prefix::::::name:::.redis.{blocked_clients,connected_clients,connected_slaves}'], 'from' => '-72hours'),
    graphiteStat0090dCons: graphite_url([':::scheme_prefix::::::name:::.redis.{blocked_clients,connected_clients,connected_slaves}'], 'from' => '-90days'),
    graphiteStat0012hHits: graphite_url(['perSecond(:::scheme_prefix::::::name:::.redis.{keyspace_hits,keyspace_misses})'], 'from' => '-12hours'),
    graphiteStat0072hHits: graphite_url(['perSecond(:::scheme_prefix::::::name:::.redis.{keyspace_hits,keyspace_misses})'], 'from' => '-72hours'),
    graphiteStat0090dHits: graphite_url(['perSecond(:::scheme_prefix::::::name:::.redis.{keyspace_hits,keyspace_misses})'], 'from' => '-90days'),
    graphiteStat0012hMem: graphite_url([':::scheme_prefix::::::name:::.redis.used_memory'], 'from' => '-12hours'),
    graphiteStat0072hMem: graphite_url([':::scheme_prefix::::::name:::.redis.used_memory'], 'from' => '-72hours'),
    graphiteStat0090dMem: graphite_url([':::scheme_prefix::::::name:::.redis.used_memory'], 'from' => '-90days'),
    refresh: node['monitor']['default_refresh']
  )
  not_if { node['monitor']['metric_disabled'] }
end
