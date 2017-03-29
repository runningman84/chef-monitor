#
# Cookbook Name:: monitor
# Recipe:: _install_redis
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
