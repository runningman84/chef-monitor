#
# Cookbook Name:: monitor
# Recipe:: _transport_snssqs
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

node.override['sensu']['use_ssl'] = false

# https://github.com/SimpleFinance/sensu-transport-snssqs
sensu_gem 'sensu-transport-snssqs' do
  version '2.0.4'
  action :install
end

cookbook_file '/opt/sensu/embedded/lib/ruby/gems/2.3.0/gems/sensu-transport-snssqs-2.0.4/lib/sensu/transport/snssqs.rb' do
  source 'transport/snssqs.rb'
  owner 'root'
  group 'root'
  mode 00644
end

if node.key?('ec2') && node['ec2'].key?('placement_availability_zone')
  region = node['ec2']['placement_availability_zone'].scan(/[a-z]+\-[a-z]+\-[0-9]+/)
  if region.count > 0 && node['monitor']['snsqs_region'].nil?
    node.set['monitor']['snssqs_region'] = region.first
  end
end

sensu_snippet 'snssqs' do
  if node['recipes'].include?('monitor::master')
    content(
      max_number_of_messages: node['monitor']['snssqs_max_number_of_messages'].to_i,
      wait_time_seconds: node['monitor']['snssqs_wait_time_seconds'].to_i,
      region: node['monitor']['snssqs_region'],
      consuming_sqs_queue_url: node['monitor']['snssqs_consuming_sqs_queue_url'],
      publishing_sns_topic_arn: node['monitor']['snssqs_publishing_sns_topic_arn']
    )
  else
    content(
      region: node['monitor']['snssqs_region'],
      publishing_sns_topic_arn: node['monitor']['snssqs_publishing_sns_topic_arn']
    )
  end
end

node.override['sensu']['service_max_wait'] = 10 + node['monitor']['snssqs_wait_time_seconds'].to_i * 2
