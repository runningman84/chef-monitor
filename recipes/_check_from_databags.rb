#
# Cookbook Name:: monitor
# Recipe:: _check_from_databags
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

check_definitions = if Chef::Config[:solo]
                      data_bag('sensu_checks').map do |item|
                        data_bag_item('sensu_checks', item)
                      end
                    elsif Chef::DataBag.list.key?('sensu_checks')
                      search(:sensu_checks, '*:*')
                    else
                      []
                    end

check_definitions.each do |check|
  sensu_check check['id'] do
    type check['type']
    command check['command']
    subscribers check['subscribers']
    interval check['interval']
    handlers check['handlers']
    additional check['additional']
  end
end
