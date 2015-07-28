name 'monitor'
maintainer 'Philipp H'
maintainer_email 'phil@hellmi.de'
license 'Apache 2.0'
description 'A cookbook for monitoring services, using Sensu, a monitoring framework.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.0.10'

%w(
  ubuntu
  debian
  centos
  redhat
  fedora
).each do |os|
  supports os
end

depends 'sudo'
depends 'yum-epel'
depends 'build-essential'
depends 'sensu'
depends 'uchiwa'
