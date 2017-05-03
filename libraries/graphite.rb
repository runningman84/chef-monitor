#
# Cookbook Name:: monitor
# Library:: graphite
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

def graphite_url(targets=[], options={})
  return nil if node['monitor']['graphite_server_url'].nil?
  return nil if targets.count.zero?

  options['from'] = '-12hours' unless options.key?('from')
  options['to'] = 'now' unless options.key?('to')
  options['width'] = 500 unless options.key?('width')
  options['height'] = 200 unless options.key?('height')

  options['width'] = options['width'].to_i.to_s
  options['height'] = options['height'].to_i.to_s

  baseurl = node['monitor']['graphite_server_url'] + '/render?'

  # baseargs = "from=#{from}&until=#{to}&width=#{width.to_i.to_s}&height=#{height.to_i.to_s}"
  suffix = 'uchiwa_force_image=.jpg'

  params = []

  options.each do |key,value|
    params << "#{key}=#{value}"
  end

  targets.each do |target|
    params << 'target=' + target
  end

  [baseurl, params, suffix].join('&')
end
