include_attribute 'sensu'

override['sensu']['use_embedded_ruby'] = true
override['sensu']['client_deregister_on_stop'] = false
override['uchiwa']['add_repo'] = false
if node['platform'].include?('ubuntu')
  override['sensu']['apt_repo_codename'] = node['lsb']['codename']
end
override['sensu']['apt_repo_url'] = 'https://sensu.global.ssl.fastly.net/apt'
# override['uchiwa']['apt_repo_url'] = 'https://sensu.global.ssl.fastly.net/apt'
override['sensu']['yum_repo_url'] = 'https://sensu.global.ssl.fastly.net'
# override['uchiwa']['yum_repo_url'] = 'https://sensu.global.ssl.fastly.net'
override['sensu']['msi_repo_url'] = 'https://sensu.global.ssl.fastly.net/msi/'
override['sensu']['version'] = '1.2.0-1'
override['uchiwa']['version'] = '1.1.3-1'

default['monitor']['redis_address'] = nil
default['monitor']['redis_db'] = nil
default['monitor']['rabbitmq_address'] = nil
default['monitor']['api_address'] = nil
default['monitor']['graphite_address'] = nil
default['monitor']['influxdb_address'] = nil

default['monitor']['transport'] = 'rabbitmq'

default['monitor']['master_search_query'] = 'recipes:monitor\\:\\:master'
default['monitor']['graphite_search_query'] = 'recipes:graphite\\:\\:carbon'
default['monitor']['influxdb_search_query'] = 'recipes:influxdb\\:\\:default'

default['monitor']['environment_aware_search'] = false
default['monitor']['use_local_ipv4'] = false

default['monitor']['additional_client_attributes'] = Mash.new

default['monitor']['use_sensu_plugins'] = true
default['monitor']['use_nagios_plugins'] = false
default['monitor']['use_system_profile'] = false
default['monitor']['use_check_os'] = true
default['monitor']['use_statsd_input'] = false

default['monitor']['sudo_commands'] = []

default['monitor']['default_handlers'] = ['debug']
default['monitor']['default_interval'] = 60
default['monitor']['default_occurrences'] = 5
default['monitor']['default_handler_timeout'] = 300
default['monitor']['default_refresh'] = 1800
default['monitor']['standalone_mode'] = true
default['monitor']['safe_mode'] = true
default['monitor']['deregistration_invalidation_duration'] = 1000

default['monitor']['metric_handlers'] = ['debug']
default['monitor']['metric_interval'] = 60
default['monitor']['metric_occurrences'] = 2
default['monitor']['metric_disabled'] = false

# platform
if platform_family?("windows")
  default['monitor']['client_extension_dir'] = 'C:\etc\sensu\extensions\client'
  default['monitor']['server_extension_dir'] = 'C:\etc\sensu\extensions\server'
else
  default['monitor']['client_extension_dir'] = '/etc/sensu/extensions/client'
  default['monitor']['server_extension_dir'] = '/etc/sensu/extensions/server'
end

default['monitor']['snssqs_max_number_of_messages'] = 10
default['monitor']['snssqs_wait_time_seconds'] = 2
default['monitor']['snssqs_region'] = nil
default['monitor']['snssqs_consuming_sqs_queue_url'] = nil
default['monitor']['snssqs_publishing_sns_topic_arn'] = nil
default['monitor']['snssqs_statsd_addr'] = ''
default['monitor']['snssqs_statsd_namespace'] = 'snssqs'
default['monitor']['snssqs_statsd_sample_rate'] = 1
default['monitor']['access_key_id'] = nil
default['monitor']['secret_access_key'] = nil

default['monitor']['active_handlers']['chef_node'] = false
default['monitor']['active_handlers']['ec2_node'] = false
default['monitor']['active_handlers']['hipchat'] = false
default['monitor']['active_handlers']['mailer'] = false
default['monitor']['active_handlers']['pagerduty'] = false
default['monitor']['active_handlers']['relay'] = false

default['monitor']['signature_file'] = '/etc/ssh/ssh_host_rsa_key'

# grpahite scheme
default['monitor']['scheme_prefix'] = 'sensu.default.unknown.unknown.'
# remedy defaults deprecated
default['monitor']['remedy_app'] = nil
default['monitor']['remedy_group'] = nil
default['monitor']['remedy_component'] = nil

# build-essential
normal['build-essential']['compile_time'] = true

# rabbitmq
default['rabbitmq']['use_distro_version'] = true
if node['platform'].include?('ubuntu')
  # if node['lsb']['release'] == '14.04'
  default['rabbitmq']['use_distro_version'] = false
  # default['rabbitmq']['version'] = '3.5.7'
  # end
elsif node['platform_family'].include?('rhel')
  default['rabbitmq']['use_distro_version'] = false
end
