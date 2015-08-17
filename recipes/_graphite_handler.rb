#
# Cookbook Name:: monitor
# Recipe:: _graphite_handler
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

include_recipe 'monitor::_graphite_search'

sensu_handler 'graphite' do
  type 'tcp'
  socket(
    host: node['sensu']['graphite']['host'],
    port: node['sensu']['graphite']['port']
  )
  mutator 'only_check_output'
  not_if node['sensu']['graphite']['host'].nil?
end

if node['monitor']['use_nagios_plugins']
  include_recipe 'monitor::_nagios_perfdata'

  sensu_handler 'graphite_perfdata' do
    type 'tcp'
    socket(
      host: node['sensu']['graphite']['host'],
      port: node['sensu']['graphite']['port']
    )
    mutator 'nagios_perfdata'
  end
end
