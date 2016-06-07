#
# Cookbook Name:: monitor
# Recipe:: _maintenance
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

include_recipe 'monitor::_filters'

cookbook_file '/opt/sensu/embedded/bin/handler-sensu-maintenance-custom.rb' do
  source 'handlers/maintenance.rb'
  owner 'root'
  group 'root'
  mode 00755
end

sensu_handler 'maintenance' do
  type 'pipe'
  command 'handler-sensu-maintenance-custom.rb'
  timeout node['monitor']['default_handler_timeout']
end
