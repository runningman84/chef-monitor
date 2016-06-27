#
# Cookbook Name:: monitor
# Recipe:: client
#
# Copyright 2013, Sean Porter Consulting
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

include_recipe "monitor::_transport_#{node['monitor']['transport']}"

node.override['sensu']['transport']['name'] = node['monitor']['transport']

include_recipe 'sensu::default'

ip_type = node['monitor']['use_local_ipv4'] ? 'local_ipv4' : 'public_ipv4'

client_attributes = node['monitor']['additional_client_attributes'].to_hash
client_subscriptions = []

client_name = node.name

if node.key?('ec2')
  %w(
    ami_id
    instance_id
    instance_type
    placement_availability_zone
    kernel_id
    profile
  ).each do |id|
    key = "ec2_#{id}"
    key = 'ec2_av_zone' if id == 'placement_availability_zone'

    client_attributes[key] = node['ec2'][id] if node['ec2'].key?(id)
  end

  if node['ec2'].key?('placement_availability_zone')
    region = node['ec2']['placement_availability_zone'].scan(/[a-z]+\-[a-z]+\-[0-9]+/)
    if region.count > 0
      client_attributes['ec2_region'] = region.first
      client_subscriptions << "region:#{region.first}"
    end
  end

end

if node.key?('stack')
  %w(
    name
    id
    account_id
  ).each do |id|
    key = "ec2_stack_#{id}"
    key = 'ec2_account_id' if id == 'account_id'

    client_attributes[key] = node['stack'][id] if node['stack'].key?(id)
  end
  client_subscriptions << "stack_name:#{client_attributes['ec2_stack_name']}" if client_attributes.key?('ec2_stack_name')
  client_subscriptions << "account_id:#{client_attributes['ec2_account_id']}" if client_attributes.key?('ec2_account_id')
end

if node.key?('cloud')
  %w(
    local_ipv4
    public_ipv4
    provider
  ).each do |id|
    key = "cloud_#{id}"
    client_attributes[key] = node['cloud'][id] if node['cloud'].key?(id)
  end
  client_subscriptions << "provider:#{client_attributes['cloud_provider']}" if client_attributes.key?('cloud_provider')
end

%w(
  platform
  platform_version
  platform_family
).each do |key|
  client_attributes[key] = node[key] if node.key?(key)
end

client_attributes['chef_env'] = node.chef_environment

org = Chef::Config[:chef_server_url].scan(%r{/http.*\/organizations\/(.*)/})
client_attributes['chef_org'] = org.first.first if org.count > 0

# deprecated
%w(
  scheme_prefix
  remedy_app
  remedy_group
  remedy_component
).each do |key|
  next unless node['monitor'].key?(key)
  client_attributes[key] = node['monitor'][key] if node['monitor'][key]
end

node.override['sensu']['name'] = client_name

node['roles'].each do |role|
  client_subscriptions << "role:#{role}"
end
client_subscriptions << "env:#{node.chef_environment}"
client_subscriptions << "os:#{node['os']}"
client_subscriptions << 'all'

sensu_client client_name do
  if node.key?('cloud') && node['cloud'].key?(ip_type)
    address node['cloud'][ip_type] || node['ipaddress']
  else
    address node['ipaddress']
  end
  subscriptions client_subscriptions
  additional client_attributes
end

include_recipe 'monitor::_plugins_sensu' if node['monitor']['use_sensu_plugins']
include_recipe 'monitor::_plugins_nagios' if node['monitor']['use_nagios_plugins']
include_recipe 'monitor::_system_profile' if node['monitor']['use_system_profile']

include_recipe "monitor::_check_#{node['os']}"

include_recipe 'sensu::client_service'
