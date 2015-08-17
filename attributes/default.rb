include_attribute 'sensu'

override['sensu']['use_embedded_ruby'] = true
override['sensu']['version'] = '0.20.3-1'
override['uchiwa']['version'] = '0.10.3-1'

default['monitor']['master_address'] = nil
default['monitor']['master_search_query'] = 'recipes:monitor\\:\\:master'
default['monitor']['graphite_search_query'] = 'recipes:graphite\\:\\:carbon'

default['monitor']['environment_aware_search'] = false
default['monitor']['use_local_ipv4'] = false

default['monitor']['additional_client_attributes'] = Mash.new

default['monitor']['use_nagios_plugins'] = false
default['monitor']['use_system_profile'] = false
default['monitor']['use_statsd_input'] = false

default['monitor']['sudo_commands'] = []

default['monitor']['default_handlers'] = ['debug']
default['monitor']['default_interval'] = 60
default['monitor']['default_occurrences'] = 2
default['monitor']['metric_handlers'] = ['debug']
default['monitor']['metric_interval'] = 60
default['monitor']['metric_occurrences'] = 2

default['monitor']['client_extension_dir'] = '/etc/sensu/extensions/client'
default['monitor']['server_extension_dir'] = '/etc/sensu/extensions/server'

# grpahite scheme
default['monitor']['scheme_prefix'] = 'sensu.default.'
# remedy defaults
default['monitor']['remedy_app'] = nil
default['monitor']['remedy_group'] = nil
default['monitor']['remedy_component'] = nil

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

# build-essential
normal['build-essential']['compile_time'] = true
