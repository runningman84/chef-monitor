#
# Cookbook Name:: monitor
# Recipe:: _handler_slack
#
# Copyright 2017, Patrick R.
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
unless node['monitor']['slack_webhook'].nil?

  sensu_gem 'sensu-plugins-slack' do
    version node['monitor']['sensu_plugins']['slack']
  end

  include_recipe 'monitor::_filters'

  cookbook_file node['monitor']['slack_message_template'] do
    source 'handlers/message_templates/slack_message.json.erb'
    owner node['sensu']['user']
    group node['sensu']['group']
    mode '0755'
  end

  sensu_snippet 'slack' do
    content(
      webhook_url: node['monitor']['slack_webhook'],
      payload_template: node['monitor']['slack_message_template']
    )
  end

  sensu_handler 'slack' do
    type 'pipe'
    command 'handler-slack.rb'
    filters ['occurrences']
    severities %w(warning critical)
    timeout node['monitor']['default_handler_timeout']
  end

  node.set['monitor']['active_handlers']['slack'] = true

end
