Description [![Build Status](https://travis-ci.org/runningman84/chef-monitor.svg?branch=master)](https://travis-ci.org/runningman84/chef-monitor)
===========

Monitor is a cookbook for monitoring services, using Sensu, a
monitoring framework. The default recipe installs & configures the
Sensu client (monitoring agent), as well as common service check
dependencies. This cookbook supports multiple transports:
* rabbitmq (default)
* redis
* snssqs

The master recipe installs & configures the Sensu server,
API, dashboard, & their dependencies (eg. RabbitMQ & Redis).
This cookbook also supports external redis servers using the `redis_address`
attribute.

Autoscaling sensu servers can be build using an external redis (e.g. aws elastic cache)
and snssqs transport (using sns and sqs and standalone only checks).

The cookbook contains preconfigured handlers for ec2 and chef 
in order to remove ephemeral instances without creating incidents.

Learn more about Sensu [Here](http://docs.sensuapp.org/).

The only transport working for Windows is currently snssqs.

Garbage collection for Sensu checks doesn't work under Windows (zap_directory).
If you remove checks, you specifically need to delete the .json from .\conf.d\checks

Requirements
============

The [Sensu](http://community.opscode.com/cookbooks/sensu) and [sudo](http://community.opscode.com/cookbooks/sudo) cookbooks.

Attributes
==========

`node["monitor"]["transport"]` - Defaults to rabbitmq.
Supports rabbitmq, redis and snssqs

`node["monitor"]["master_address"]` - Bypass the chef node search and
explicitly set the address to reach the master server. Only used 
for rabbitmq and redis transport.

`node["monitor"]["environment_aware_search"]` - Defaults to false.
If true, will limit search to the node's chef_environment.

`node["monitor"]["use_local_ipv4"]` - Defaults to false. If true,
use cloud local\_ipv4 when available instead of public\_ipv4.

`node["monitor"]["sensu_plugin_version"]` - Sensu Plugin library
version.

`node["monitor"]["additional_client_attributes"]` - Additional client
attributes to be passed to the sensu_client LWRP.

`node["monitor"]["default_handlers"]` - Default event handlers.

`node["monitor"]["metric_handlers"]` - Metric event handlers.

Usage
=====

Example: To monitor a Chef node, include
"recipe[monitor::default]" in its run list.

Please create application specific checks within your application cookbooks.
This cookbook only contains base checks.
