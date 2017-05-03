#
# Cookbook Name:: monitor
# Recipe:: _system_profile
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

include_recipe 'monitor::_extensions'

sensu_snippet 'system_profile' do
  content(
    interval: node['monitor']['metric_interval'],
    handler: 'metrics'
  )
end

cookbook_file File.join(node['monitor']['client_extension_dir'], 'system_profile.rb') do
  source 'extensions/system_profile.rb'
  mode 0o755
  notifies :create, 'ruby_block[sensu_service_trigger]', :immediately
end

%w(
  load_metrics
  cpu_metrics
  memory_metrics
  interface_metrics
).each do |key|
  file "/etc/sensu/conf.d/checks/#{key}.json" do
    action :delete
    notifies :create, 'ruby_block[sensu_service_trigger]', :immediately
  end
end
