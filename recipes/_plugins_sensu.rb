#
# Cookbook Name:: monitor
# Recipe:: _plugins
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

include_recipe 'build-essential::default'

if node['platform_family'].include?('windows')
  node['monitor']['sensu_plugins'].each do |name, version|
    gem_package "sensu-plugins-#{name}" do
      gem_binary('C:\\opt\\sensu\\embedded\\bin\\gem.cmd')
      options('--force')
      version version if version != 'latest'
    end
  end

else
  node['monitor']['sensu_plugins'].each do |name, version|
    sensu_gem "sensu-plugins-#{name}" do
      version version if version != 'latest'
    end
  end

end
