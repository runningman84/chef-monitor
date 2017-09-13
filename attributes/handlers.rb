# pagerduty
default['monitor']['pagerduty_api_key'] = nil

# graphite
default['monitor']['graphite_address'] = nil
default['monitor']['graphite_port'] = nil
default['monitor']['graphite_server_url'] = nil

# hipchat
default['monitor']['hipchat_server_url'] = 'https://api.hipchat.com'
default['monitor']['hipchat_apikey'] = nil
default['monitor']['hipchat_apiversion'] = 'v1'
default['monitor']['hipchat_room'] = 'Ops'
default['monitor']['hipchat_from'] = 'Sensu'

# slack
default['monitor']['slack_webhook'] = nil
default['monitor']['slack_message_template'] = node['sensu']['directory'] + '/handlers/slack_message.json.erb'
default['monitor']['slack_severities'] = %w(warning critical)

# mailer
default['monitor']['mail_from'] = 'sensu'
default['monitor']['delivery_method'] = 'smtp'
default['monitor']['smtp_address'] = 'localhost'
default['monitor']['smtp_port'] = 25
default['monitor']['smtp_domain'] = 'localhost.localdomain'
default['monitor']['smtp_username'] = nil
default['monitor']['smtp_password'] = nil
default['monitor']['smtp_authentication'] = nil
default['monitor']['smtp_enable_starttls_auto'] = true

# ec2
default['monitor']['ec2_states'] = ['terminated','stopping','shutting-down','stopped']

# influxdb
default['monitor']['influxdb_address'] = nil
default['monitor']['influxdb_database'] = 'stats'
default['monitor']['influxdb_host'] = 'localhost'
default['monitor']['influxdb_port'] = 8086
default['monitor']['influxdb_username'] = 'stats'
default['monitor']['influxdb_password'] = 'stats'
