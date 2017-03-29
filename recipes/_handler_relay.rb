#
# Cookbook Name:: monitor
# Recipe:: _handler_ec2_node
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

include_recipe 'monitor::_extensions'
include_recipe 'monitor::_search_graphite'

if node['sensu'].key?('graphite')

  unless node['sensu']['graphite']['host'].nil?

    cookbook_file File.join(node['monitor']['server_extension_dir'], 'relay.rb') do
      source 'extensions/relay.rb'
      mode 0755
      notifies :create, 'ruby_block[sensu_service_trigger]', :immediately
    end

    cookbook_file File.join(node['monitor']['server_extension_dir'], 'metrics.rb') do
      source 'extensions/metrics.rb'
      mode 0755
      notifies :create, 'ruby_block[sensu_service_trigger]', :immediately
    end

    json = {
      graphite: {
        host: node['sensu']['graphite']['host'],
        port: node['sensu']['graphite']['port']
      }
    }

    sensu_snippet 'relay' do
      content(
        json
      )
    end

    node.set['monitor']['active_handlers']['relay'] = true

  end

end
