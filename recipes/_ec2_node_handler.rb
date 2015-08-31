#
# Cookbook Name:: monitor
# Recipe:: _ec2_node_handler
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

sensu_gem 'sensu-plugins-aws' do
  version '1.2.0'
end

include_recipe 'monitor::_filters'

sensu_handler 'chef_node' do
  type 'pipe'
  command 'handler-ec2_node.rb'
  filters ['keepalives']
  severities %w(warning critical)
  timeout node['monitor']['default_handler_timeout']
end
