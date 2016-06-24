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

node.set['sensu']['use_ssl'] = false

# https://github.com/SimpleFinance/sensu-transport-snssqs
sensu_gem 'sensu-transport-snssqs' do
  action :install
end

sensu_snippet 'snssqs' do
  content(
    max_number_of_messages: node['monitor']['snsqs']['max_number_of_messages'],
    wait_time_seconds: node['monitor']['snsqs']['wait_time_seconds'],
    region: node['monitor']['snsqs']['region'],
    consuming_sqs_queue_url: node['monitor']['snsqs']['consuming_sqs_queue_url'],
    publishing_sns_topic_arn: node['monitor']['snsqs']['publishing_sns_topic_arn']
  )
end

# {
#  "snssqs": {
#    "max_number_of_messages": 10,
#    "wait_time_seconds": 2,
#    "region": "{{ AWS_REGION }}",
#    "consuming_sqs_queue_url": "{{ SENSU_QUEUE_URL }}",
#    "publishing_sns_topic_arn": "{{ SENSU_SNS_ARN }}"
#    },
# }
