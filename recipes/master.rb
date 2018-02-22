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

if node['monitor']['rabbitmq_address'].nil?
  include_recipe 'monitor::_install_rabbitmq' if node['monitor']['transport'] == 'rabbitmq'
end

if node['monitor']['redis_address'].nil?
  include_recipe 'monitor::_install_redis'
else
  node.override['sensu']['redis']['host'] = node['monitor']['redis_address']
end
node.override['sensu']['redis']['db'] = node['monitor']['redis_db'] unless node['monitor']['redis_db'].nil?

node.override['sensu']['use_ssl'] = false unless node['monitor']['transport'] == 'rabbitmq'

include_recipe 'sensu::default'

include_recipe 'monitor::_fix_service'

node.override['sensu']['transport']['name'] = node['monitor']['transport']
include_recipe "monitor::_transport_#{node['monitor']['transport']}"
node.override['sensu']['api']['host'] = 'localhost'

active_default_handlers = []

node['monitor']['default_handlers'].each do |handler_name|
  if %w(chef_node ec2_node hipchat mailer pagerduty slack).include? handler_name
    include_recipe "monitor::_handler_#{handler_name}"
    active_default_handlers << handler_name if node['monitor']['active_handlers'][handler_name]
  else
    active_default_handlers << handler_name
  end
end

include_recipe 'monitor::_handler_deregistration'
include_recipe 'monitor::_handler_maintenance'

active_metric_handlers = []

node['monitor']['metric_handlers'].each do |handler_name|
  if %w(relay influxdb).include? handler_name
    include_recipe "monitor::_handler_#{handler_name}"
    active_metric_handlers << handler_name if node['monitor']['active_handlers'][handler_name]
  else
    active_metric_handlers << handler_name
  end
end

sensu_handler 'default' do
  type 'set'
  handlers active_default_handlers.uniq
end

sensu_handler 'metrics' do
  type 'set'
  handlers active_metric_handlers.uniq
end

include_recipe 'build-essential::default' unless node['os'] == 'windows'
sensu_gem 'sensu-plugins-sensu' do
  version node['monitor']['sensu_gem_versions']['sensu-plugins-sensu']
end
sensu_gem 'sensu-plugins-uchiwa' do
  version node['monitor']['sensu_gem_versions']['sensu-plugins-uchiwa']
end

include_recipe 'monitor::client'
include_recipe 'monitor::_check_redis'
include_recipe 'monitor::_check_rabbitmq' if node['monitor']['transport'] == 'rabbitmq'
include_recipe 'monitor::_check_from_databags'

include_recipe 'sensu::server_service'
include_recipe 'sensu::api_service'
include_recipe 'sensu::client_service'

include_recipe 'uchiwa'
