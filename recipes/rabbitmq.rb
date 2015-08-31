#
# Cookbook Name:: monitor
# Recipe:: rabbitmq
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

include_recipe 'monitor::_rabbitmq'

sensu_check 'rabbitmq_process' do
  command 'check-process.rb -p erlang.*beam\.smp.*rabbitmq_server -w 2 -c 3 -C 1 -u rabbitmq'
  handlers ['default']
  standalone true
  interval node['monitor']['default_interval']
  additional(
    occurrences: node['monitor']['default_occurrences']
  )
end

sensu_check 'rabbitmq_overview_metrics' do
  type 'metric'
  command 'metrics-rabbitmq-overview.rb --scheme :::scheme_prefix::::::name:::.rabbitmq'
  handlers ['metrics']
  standalone true
  interval node['monitor']['metric_interval']
  additional(
    dependencies: ['rabbitmq_process'],
    occurrences: node['monitor']['metric_occurrences']
  )
end
