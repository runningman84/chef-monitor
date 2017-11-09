#
# Cookbook Name:: monitor
# Recipe:: _handler_mailer
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

sensu_gem 'sensu-plugins-mailer' do
  version node['monitor']['sensu_gem_versions']['sensu-plugins-mailer']
end

sensu_snippet 'mailer' do
  content(
    mail_from: node['monitor']['mail_from'],
    delivery_method: node['monitor']['delivery_method'],
    smtp_address: node['monitor']['smtp_address'],
    smtp_port: node['monitor']['smtp_port'],
    smtp_domain: node['monitor']['smtp_domain'],
    smtp_username: node['monitor']['smtp_username'],
    smtp_password: node['monitor']['smtp_password'],
    smtp_authentication: node['monitor']['smtp_authentication'],
    smtp_enable_starttls_auto: node['monitor']['smtp_enable_starttls_auto']
  )
end

sensu_handler 'mailer' do
  type 'pipe'
  command 'handler-mailer.rb'
  filters ['occurrences']
end

node.set['monitor']['active_handlers']['mailer'] = true
