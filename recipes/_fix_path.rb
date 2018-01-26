#
# Cookbook Name:: monitor
# Recipe:: _handler_hipchat
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

# temporary fix for
# https://github.com/sensu/sensu-chef/issues/562

windows_path 'C:\opt\sensu\embedded\bin' do
  action :add
end
