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

require 'digest'
require 'resolv'

node.override['sensu']['use_ssl'] = false unless node['monitor']['transport'] == 'rabbitmq'

include_recipe 'sensu::default'

if node['platform_family'].include?('windows')
  include_recipe 'monitor::_fix_path'
else
  include_recipe 'monitor::_fix_service'
end

include_recipe "monitor::_transport_#{node['monitor']['transport']}"
node.override['sensu']['transport']['name'] = node['monitor']['transport']

ip_type = node['monitor']['use_local_ipv4'] ? 'local_ipv4' : 'public_ipv4'

client_attributes = node['monitor']['additional_client_attributes'].to_hash
client_subscriptions = []

client_attributes['signature'] = (Digest::SHA256.hexdigest File.read node['monitor']['signature_file'])[0..31] unless node['platform_family'].include?('windows')
client_attributes['safe_mode'] = node['monitor']['safe_mode']
client_attributes['standalone_mode'] = node['monitor']['standalone_mode']
client_attributes['transport'] = node['monitor']['transport']

client_attributes['keepalive'] ||= {}
client_attributes['keepalive']['thresholds'] ||= {}
client_attributes['keepalive']['thresholds']['warning'] ||= 300
client_attributes['keepalive']['thresholds']['critical'] ||= 900

client_attributes['influxdb'] ||= {}
client_attributes['influxdb']['tags'] ||= {}

client_name = node.name

if node.key?('ec2') && node['ec2'].is_a?(Hash)
  client_subscriptions << 'aws:ec2'
  client_attributes['ec2'] = {}
  %w(
    ami_id
    instance_id
    instance_type
    placement_availability_zone
    kernel_id
    profile
  ).each do |id|
    key = id
    key = 'az' if id == 'placement_availability_zone'
    client_attributes['ec2'][key] = node['ec2'][id] if node['ec2'].key?(id)
  end

  if node['ec2'].key?('placement_availability_zone')
    region = node['ec2']['placement_availability_zone'].scan(/[a-z]+\-[a-z]+\-[0-9]+/)
    if region.count > 0
      client_attributes['ec2']['region'] = region.first
      client_attributes['aws_mngt_console'] = "https://#{region.first}.console.aws.amazon.com/ec2/v2/home?region=#{region.first}#Instances:search=#{node['ec2']['instance_id']};sort=Name"
      client_subscriptions << "region:#{region.first}"
    end

    begin
      cmd = Mixlib::ShellOut.new("aws ec2 describe-tags --filters 'Name=resource-id,Values=#{node['ec2']['instance_id']}' --region #{client_attributes['ec2']['region']} --output=json")
      cmd.run_command
      cmd.error!

      client_attributes['tags'] = {}

      parsed = JSON.parse(cmd.stdout)
      parsed['Tags'].each do |tag|
        client_attributes['tags'][tag['Key']] = tag['Value']
      end
    rescue StandardError => e
      Chef::Log.warn("Could not setup ec2 tags: #{e.message}")
    end

  end

  if node.key?('stack') && node['stack'].is_a?(Hash)
    %w(
      name
      id
      account_id
    ).each do |id|
      key = "stack_#{id}"
      key = 'account_id' if id == 'account_id'

      client_attributes['ec2'][key] = node['stack'][id].to_s if node['stack'].key?(id)
    end
    client_subscriptions << "stack_name:#{client_attributes['ec2']['stack_name']}" if client_attributes['ec2'].key?('stack_name')
    client_subscriptions << "account_id:#{client_attributes['ec2']['account_id']}" if client_attributes['ec2'].key?('account_id')
  end

  client_attributes['influxdb']['tags']['aws_account_id'] = client_attributes['ec2']['account_id'] if client_attributes['ec2'].key?('account_id')
  client_attributes['influxdb']['tags']['aws_region'] = client_attributes['ec2']['region'] if client_attributes['ec2'].key?('region')
  client_attributes['influxdb']['tags']['aws_az'] = client_attributes['ec2']['az'] if client_attributes['ec2'].key?('az')
  client_attributes['influxdb']['tags']['aws_ami_id'] = client_attributes['ec2']['ami_id'] if client_attributes['ec2'].key?('ami_id')
  client_attributes['influxdb']['tags']['aws_instance_type'] = client_attributes['ec2']['instance_type'] if client_attributes['ec2'].key?('instance_type')
  client_attributes['influxdb']['tags']['aws_stack_name'] = client_attributes['ec2']['stack_name'] if client_attributes['ec2'].key?('stack_name')

end

if node.key?('cloud_v2') && node['cloud_v2'].is_a?(Hash)
  client_attributes['cloud'] = {}
  %w(
    local_ipv4
    local_hostname
    public_ipv4
    public_hostname
    provider
  ).each do |key|
    client_attributes['cloud'][key] = node['cloud_v2'][key].to_s if node['cloud_v2'].key?(key)
  end
  client_subscriptions << "provider:#{client_attributes['cloud']['provider']}" if client_attributes['cloud'].key?('provider')
  client_attributes['influxdb']['tags']['cloud_provider'] = client_attributes['cloud']['provider'] if client_attributes['cloud'].key?('provider')
end

%w(
  platform
  platform_version
  platform_family
).each do |key|
  client_attributes[key] = node[key].to_s if node.key?(key)
end
client_attributes['influxdb']['tags']['platform'] = client_attributes['platform'] if client_attributes.key?('platform')
client_attributes['influxdb']['tags']['platform_version'] = client_attributes['platform_version'] if client_attributes.key?('platform_version')

client_attributes['chef'] = {}
client_attributes['chef']['endpoint'] = Chef::Config[:chef_server_url]
org = Chef::Config[:chef_server_url].scan(%r{/http.*\/organizations\/(.*)/})
client_attributes['chef']['organisation'] = org.first.first if org.count > 0
client_attributes['chef']['environment'] = node.chef_environment
client_attributes['chef']['client'] = Chef::Config[:node_name]
client_attributes['chef']['key'] = Chef::Config[:client_key]

client_attributes['influxdb']['tags']['chef_org'] = client_attributes['chef']['organisation'] if client_attributes['chef'].key?('organisation')
client_attributes['influxdb']['tags']['chef_env'] = client_attributes['chef']['organisation'] if client_attributes['chef'].key?('environment')

%w(
  scheme_prefix
).each do |key|
  next unless node['monitor'].key?(key)
  client_attributes[key] = node['monitor'][key] if node['monitor'][key]
end

node.override['sensu']['name'] = client_name

node['roles'].each do |role|
  client_subscriptions << "role:#{role}"
  client_subscriptions << "role_by_env:#{role}_#{node.chef_environment}"
end
client_subscriptions << "env:#{node.chef_environment}"
client_subscriptions << "os:#{node['os']}"
client_subscriptions << 'all'

client_attributes['influxdb']['tags']['os'] = node['os']

sensu_client client_name do
  if node.key?('cloud') && node['cloud'].key?(ip_type)
    if node['cloud'][ip_type] =~ Resolv::IPv4::Regex
      address node['cloud'][ip_type]
    else
      address node['ipaddress']
    end
  else
    address node['ipaddress']
  end
  subscriptions client_subscriptions
  additional client_attributes
end

include_recipe 'monitor::_plugins_sensu' if node['monitor']['use_sensu_plugins']
include_recipe 'monitor::_plugins_nagios' if node['monitor']['use_nagios_plugins']
include_recipe 'monitor::_system_profile' if node['monitor']['use_system_profile']

include_recipe "monitor::_check_#{node['os']}" if node['monitor']['use_check_os']

zap_directory '/etc/sensu/conf.d/checks' do
  pattern '*.json'
  notifies :create, 'ruby_block[sensu_service_trigger]', :immediately
  not_if { node['platform_family'].include?('windows') }
end

include_recipe 'sensu::client_service' unless node['recipes'].include?('monitor::master')

directory '/var/cache/sensu' do
  owner 'sensu'
  group 'sensu'
  mode 0o755
  action :create
  not_if { node['platform_family'].include?('windows') }
end
