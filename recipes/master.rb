#
# Cookbook Name:: monitor
# Recipe:: server
#
# Copyright 2016, Philipp H
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

case node['monitor']['transport']
when 'rabbitmq'
  if node['monitor']['rabbitmq_address'].nil?
    include_recipe 'monitor::_install_rabbitmq'
    node.override['sensu']['rabbitmq']['host'] = 'localhost'
  else
    node.override['sensu']['rabbitmq']['host'] = node['monitor']['rabbitmq_address']
  end
when 'redis'
  if node['monitor']['redis_address'].nil?
    include_recipe 'monitor::_install_redis'
    node.override['sensu']['redis']['host'] = 'localhost'
  else
    node.override['sensu']['rabbitmq']['host'] = node['monitor']['redis_address']
  end
when 'snssqs'
  # nothing yet
else
  raise "Unsupported Transport #{node['monitor']['transport']}"
end

node.override['sensu']['transport']['name'] = node['monitor']['transport']
node.override['sensu']['api']['host'] = 'localhost'

include_recipe 'sensu::default'

include_recipe "monitor::_check_#{node['monitor']['transport']}"

handlers = node['monitor']['default_handlers'] + node['monitor']['metric_handlers']
handlers.each do |handler_name|
  next if handler_name == 'debug'
  include_recipe "monitor::_handler_#{handler_name}"
end

include_recipe 'monitor::_handler_deregister'
include_recipe 'monitor::_handler_maintenance'

sensu_handler 'default' do
  type 'set'
  handlers node['monitor']['default_handlers']
end

sensu_handler 'metrics' do
  type 'set'
  handlers node['monitor']['metric_handlers']
end

check_definitions = case
                    when Chef::Config[:solo]
                      data_bag('sensu_checks').map do |item|
                        data_bag_item('sensu_checks', item)
                      end
                    when Chef::DataBag.list.key?('sensu_checks')
                      search(:sensu_checks, '*:*')
                    else
                      []
                    end

check_definitions.each do |check|
  sensu_check check['id'] do
    type check['type']
    command check['command']
    subscribers check['subscribers']
    interval check['interval']
    handlers check['handlers']
    additional check['additional']
  end
end

include_recipe 'sensu::server_service'

include_recipe 'sensu::api_service'

include_recipe 'uchiwa'

include_recipe 'build-essential::default'
sensu_gem 'sensu-plugins-sensu' do
  version '0.1.0'
end
sensu_gem 'sensu-plugins-uchiwa' do
  version '0.0.3'
end

include_recipe "monitor::client"
