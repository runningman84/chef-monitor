#
# Cookbook Name:: monitor
# Recipe:: _graphite_handler
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

graphite_address = node['monitor']['graphite_address']
graphite_address = 'localhost' if node['recipes'].include?('graphite::carbon')
graphite_port = node['monitor']['graphite_port']

ip_type = node['monitor']['use_local_ipv4'] ? 'local_ipv4' : 'public_ipv4'

if graphite_address.nil?
  search_query = node['monitor']['graphite_search_query']
  search_query += " chef_environment:#{node.chef_environment}" if node['monitor']['environment_aware_search']

  Chef::Log.debug('Searching graphite server nodes using ' + search_query)
  graphite_nodes = search(:node, search_query)
  Chef::Log.debug('Found ' + graphite_nodes.count.to_s + ' graphite servers')

  if graphite_nodes.count > 0

    # Use the node with the shortest uptime, older nodes might be offline
    graphite_node = graphite_nodes.sort_by { |a| -a[:uptime_seconds] }.last
    Chef::Log.debug('Using ' + graphite_node.name + ' as gaphite server')
    graphite_address =  case
                        when graphite_node.key?('cloud')
                          graphite_node['cloud'][ip_type] || graphite_node['ipaddress']
                        else
                          graphite_node['ipaddress']
                        end

  end

end

if graphite_address.nil?
  Chef::Log.warn('Did not find any graphite node, graphite output will not work')
else
  Chef::Log.info('Setting up ' + graphite_address + ' as graphite server')
  node.override['sensu']['graphite']['host'] = graphite_address
  node.override['sensu']['graphite']['port'] = graphite_port
end
