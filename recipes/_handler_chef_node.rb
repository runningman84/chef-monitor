#
# Cookbook Name:: monitor
# Recipe:: _handler_chef_node
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

include_recipe 'build-essential::default' unless node['os'] == 'windows'

if File.exist?('/etc/chef/client.rb') && File.exist?('/etc/chef/client.pem')

  sensu_gem 'sensu-plugins-chef' do
    version node['monitor']['sensu_gem_versions']['sensu-plugins-chef']
  end

  handler_path = '/opt/sensu/embedded/bin/handler-chef-node.rb'

  node.override['monitor']['sudo_commands'] =
    node['monitor']['sudo_commands'] + [handler_path]

  include_recipe 'monitor::_sudo'

  sensu_snippet 'chef' do
    content(
      server_url: Chef::Config[:chef_server_url],
      client_name: Chef::Config[:node_name],
      client_key: Chef::Config[:client_key],
      verify_ssl: false
    )
  end

  include_recipe 'monitor::_filters'

  sensu_handler 'chef_node' do
    type 'pipe'
    command 'sudo handler-chef-node.rb'
    filters %w(keepalives chef chef_server_mode chef_same_endpoint every_3_occurrences max_300_occurrences)
    severities %w(warning critical)
    timeout node['monitor']['default_handler_timeout']
  end

  node.set['monitor']['active_handlers']['chef_node'] = true

end
