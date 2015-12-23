#
# Cookbook Name:: monitor
# Recipe:: _pagerduty_handler
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

sensu_gem 'sensu-plugins-pagerduty' do
  version '0.0.9'
end

sensu_snippet 'pagerduty' do
  content(api_key: node['monitor']['pagerduty_api_key'])
end

include_recipe 'monitor::_filters'

sensu_handler 'pagerduty' do
  type 'pipe'
  command 'handler-pagerduty.rb'
  filters ['actions']
end
