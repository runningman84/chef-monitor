#
# Cookbook Name:: monitor
# Recipe:: redis
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

include_recipe 'monitor::_redis'

sensu_check 'redis_process' do
  command 'check-process.rb -p redis-server -w 2 -c 3 -C 1'
  handlers ['default']
  standalone true
  interval node['monitor']['default_interval']
  additional(
    occurrences: node['monitor']['default_occurrences']
  )
end

sensu_check 'redis_metrics' do
  type 'metric'
  command 'metrics-redis-graphite.rb --scheme :::scheme_prefix::::::name:::.redis'
  handlers ['metrics']
  standalone true
  interval node['monitor']['metric_interval']
  additional(
    dependencies: ['redis_process'],
    occurrences: node['monitor']['metric_occurrences']
  )
  not_if { node['monitor']['metric_disabled'] }
end
