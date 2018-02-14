default['monitor']['nagios_plugin_packages'] = ['nagios-plugins']

if node['platform_family'].include?('windows')
  default['monitor']['sensu_plugins']['windows'] = '2.3.0'
else
  default['monitor']['sensu_plugins']['network-checks'] = '2.1.1'
  default['monitor']['sensu_plugins']['load-checks'] = '4.0.0'
  default['monitor']['sensu_plugins']['cpu-checks'] = '1.1.2'
  default['monitor']['sensu_plugins']['process-checks'] = '2.5.0'
  default['monitor']['sensu_plugins']['memory-checks'] = '3.1.1'
  default['monitor']['sensu_plugins']['disk-checks'] = '2.5.0'
  default['monitor']['sensu_plugins']['filesystem-checks'] = '1.0.0'
  default['monitor']['sensu_plugins']['vmstats'] = '1.0.0'
  default['monitor']['sensu_plugins']['io-checks'] = '1.0.1'
  default['monitor']['sensu_plugins']['logs'] = '1.3.1'
  if %w(/bin/systemctl /sbin/systemctl /usr/bin/systemctl /usr/sbin/systemctl).any? { |e| File.exist?(e) }
    default['monitor']['sensu_plugins']['systemd'] = '0.1.0'
  end
end

default['monitor']['sensu_optional_plugins']['slack'] = '2.0.0'

default['monitor']['sensu_gem_versions']['sensu-plugins-rabbitmq'] = '3.6.0'
default['monitor']['sensu_gem_versions']['sensu-plugins-redis'] = '2.2.1'
default['monitor']['sensu_gem_versions']['sensu-plugins-chef'] = '4.0.0'
default['monitor']['sensu_gem_versions']['sensu-plugins-aws'] = '10.2.0'
default['monitor']['sensu_gem_versions']['sensu-plugins-hipchat'] = '2.0.0'
default['monitor']['sensu_gem_versions']['sensu-plugins-mailer'] = '2.0.0'
default['monitor']['sensu_gem_versions']['sensu-plugins-pagerduty'] = '3.0.0'
default['monitor']['sensu_gem_versions']['sensu-plugins-pagerduty'] = '3.0.0'
default['monitor']['sensu_gem_versions']['aws-sdk'] = '2.10.82'
default['monitor']['sensu_gem_versions']['sensu-transport-snssqs-ng'] = '2.1.2'
default['monitor']['sensu_gem_versions']['sensu-plugins-sensu'] = '2.4.0'
default['monitor']['sensu_gem_versions']['sensu-plugins-uchiwa'] = '1.0.0'
