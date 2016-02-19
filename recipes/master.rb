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
include_recipe 'monitor::rabbitmq'

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

include_recipe 'monitor::redis'
include_recipe 'monitor::_worker'

include_recipe 'sensu::api_service'
include_recipe 'uchiwa'

include_recipe 'monitor::default'

include_recipe 'build-essential::default'

sensu_gem 'sensu-plugins-sensu' do
  version '0.1.0'
end

sensu_gem 'sensu-plugins-uchiwa' do
  version '0.0.3'
end
