#
# Cookbook Name:: monitor
# Recipe:: _transport_rabbitmq
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

master_addresses = []

ip_type = node['monitor']['use_local_ipv4'] ? 'local_ipv4' : 'public_ipv4'
master_addresses = ['localhost'] if node['recipes'].include?('monitor::master')
master_addresses = [node['monitor']['rabbitmq_address']] unless node['monitor']['rabbitmq_address'].nil?

if master_addresses.count == 0
  search_query = node['monitor']['master_search_query']
  search_query += " AND chef_environment:#{node.chef_environment}" if node['monitor']['environment_aware_search']

  Chef::Log.debug('Searching sensu master nodes using ' + search_query)
  master_nodes = search(:node, search_query)
  Chef::Log.debug('Found ' + master_nodes.count.to_s + ' sensu master nodes')

  if master_nodes.count > 0

    # Use the node with the shortest uptime, older nodes might be offline
    master_node = master_nodes.sort_by { |a| -a[:uptime_seconds] }.last
    Chef::Log.debug('Using ' + master_node.name + ' as sensu master')
    master_address =  case
                      when master_node.key?('cloud')
                        master_node['cloud'][ip_type] || master_node['ipaddress']
                      else
                        master_node['ipaddress']
                      end
    master_addresses << master_address

  end

end

if master_addresses.count == 0
  Chef::Log.warn('Did not find any master sensu node, monitoring will not work')
else
  Chef::Log.info('Setting up ' + master_addresses.join(',') + ' as sensu master')
  node.override['sensu']['rabbitmq']['hosts'] = master_addresses
end
