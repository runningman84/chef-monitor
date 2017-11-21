#
# Cookbook Name:: monitor
# Recipe:: _influxdb_handler
#
# Copyright 2015, Philipp H
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

influxdb_address = node['monitor']['influxdb_address']
influxdb_address = 'localhost' if node['recipes'].include?('influxdb::default')

ip_type = node['monitor']['use_local_ipv4'] ? 'local_ipv4' : 'public_ipv4'

if influxdb_address.nil?
  search_query = node['monitor']['influxdb_search_query']
  search_query += " AND chef_environment:#{node.chef_environment}" if node['monitor']['environment_aware_search']

  Chef::Log.debug('Searching influxdb server nodes using ' + search_query)
  influxdb_nodes = search(:node, search_query)
  Chef::Log.debug('Found ' + influxdb_nodes.count.to_s + ' influxdb servers')

  if influxdb_nodes.count > 0

    # Use the node with the shortest uptime, older nodes might be offline
    influxdb_node = influxdb_nodes.sort_by { |a| -a[:uptime_seconds] }.last
    Chef::Log.debug('Using ' + influxdb_node.name + ' as influxdb server')
    influxdb_address = if influxdb_node.key?('cloud')
                         influxdb_node['cloud'][ip_type] || influxdb_node['ipaddress']
                       else
                         influxdb_node['ipaddress']
                       end

  end

end

if influxdb_address.nil?
  Chef::Log.warn('Did not find any influxdb node, influxdb output will not work')
else
  Chef::Log.info('Setting up ' + influxdb_address + ' as influxdb server')

end
node.override['sensu']['influxdb']['host'] = influxdb_address
node.override['sensu']['influxdb']['port'] = 8086
