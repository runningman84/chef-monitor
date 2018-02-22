#
# Cookbook Name:: monitor
# Recipe:: _handler_ec2_node
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

include_recipe 'build-essential::default' unless node['os'] == 'windows'

if node.key?('ec2')

  package 'zlib1g-dev' do
    action :install
  end

  sensu_gem 'sensu-plugins-aws' do
    version node['monitor']['sensu_gem_versions']['sensu-plugins-aws']
  end

  include_recipe 'monitor::_filters'

  cookbook_file '/opt/sensu/embedded/bin/handler-ec2_node-custom.rb' do
    source 'handlers/ec2_node.rb'
    owner 'root'
    group 'root'
    mode 0o0755
  end

  sensu_snippet 'ec2_node' do
    content(
      ec2_states: node['monitor']['ec2_states']
    )
  end

  sensu_handler 'ec2_node' do
    type 'pipe'
    command 'handler-ec2_node-custom.rb'
    filters %w(keepalives ec2 every_5_occurrences max_100_occurrences)
    severities %w(warning critical)
    timeout node['monitor']['default_handler_timeout']
  end

  node.set['monitor']['active_handlers']['ec2_node'] = true

end
