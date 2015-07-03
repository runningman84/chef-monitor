#
# Cookbook Name:: monitor
# Recipe:: master
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

include_recipe 'sensu::rabbitmq'

if node['platform'] == 'ubuntu'
  # will be reverted once the upstream redis package supports package installation
  package 'redis-server' do
    action :install
  end

  service 'redis-server' do
    action [:enable, :start]
  end
elsif node['platform'] == 'centos'
  include_recipe 'yum-epel'

  # will be reverted once the upstream redis package supports package installation
  package 'redis' do
    action :install
  end

  service 'redis' do
    action [:enable, :start]
  end
else
  include_recipe 'sensu::redis'
end

include_recipe 'monitor::_worker'

include_recipe 'sensu::api_service'
include_recipe 'uchiwa'

include_recipe 'monitor::default'

#sensu_gem 'sensu-plugins-sensu' do
#  options('--prerelease') # only needed if it is in an alpha state
#  version '0.0.1.alpha.1'
#end

sensu_gem 'sensu-plugins-uchiwa' do
  version '0.0.2'
end
