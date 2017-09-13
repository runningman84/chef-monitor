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
include_recipe 'monitor::_search_influxdb'

unless node['sensu']['influxdb']['host'].nil?

  %w(influxdb multi_json em-http-request).each do |mygem|
    sensu_gem mygem
  end

  cookbook_file File.join(node['monitor']['server_extension_dir'], 'influxdb.rb') do
    source 'extensions/influxdb.rb'
    mode 0o755
    notifies :create, 'ruby_block[sensu_service_trigger]', :immediately
  end

  json = {
    database: 'sensu',
    strip_metric: 'host',
    host: node['sensu']['influxdb']['host'],
    port: node['sensu']['influxdb']['port'],
    username: 'sensu',
    password: 'sensu'
  }

  sensu_snippet 'influxdb' do
    content(
      json
    )
  end

  node.set['monitor']['active_handlers']['influxdb'] = true

end
