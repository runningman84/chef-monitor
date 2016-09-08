#
# Cookbook Name:: monitor
# Recipe:: _filters
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

sensu_filter 'actions' do
  attributes(action: 'eval: %w[create resolve].include? value.to_s')
end

sensu_filter 'keepalives' do
  attributes(
    check: {
      name: 'keepalive',
      status: 2
    },
    occurrences: 'eval: value > 2'
  )
end

sensu_filter 'ec2' do
  attributes(
    client: {
      cloud: {
        provider: 'ec2'
      }
    }
  )
end

sensu_filter 'chef' do
  attributes(
    client: {
      chef: {
        environment: 'eval: value.nil?'
      }
    }
  )
  negate true
end

sensu_filter 'chef_env_prod' do
  attributes(
    client: {
      chef: {
        environment: 'prod'
      }
    }
  )
end

sensu_filter 'occurrences' do
  attributes(occurrences: 'eval: value > :::check.occurrences|10:::')
end

sensu_filter 'every_3_occurrences' do
  attributes(occurrences: 'eval: value % 3')
end

sensu_filter 'every_10_occurrences' do
  attributes(occurrences: 'eval: value % 10')
end

sensu_filter 'max_100_occurrences' do
  attributes(occurrences: 'eval: value < 100')
end

sensu_filter 'max_300_occurrences' do
  attributes(occurrences: 'eval: value < 300')
end
