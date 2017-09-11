require 'serverspec'

# Required by serverspec
set :backend, :exec

describe package('sensu') do
  it { should be_installed }
end

describe package('uchiwa') do
  it { should be_installed }
end

describe user('sensu') do
  it { should exist }
end

describe file('/etc/sensu') do
  it { should be_directory }
  it { should be_owned_by 'root' }
end

describe file('/etc/sensu/config.json') do
  it { should contain('"name": "rabbitmq').after(/transport/) }
  it { should contain('"host": "localhost"').after(/rabbitmq/).before(/5671/) }
  it { should contain('"host": "localhost"').after(/redis/).before(/6379/) }
  it { should contain('"host": "localhost"').after(/api/).before(/4567/) }
end

describe file('/etc/sensu/conf.d') do
  it { should be_directory }
  #  it { should be_owned_by 'sensu' }
end

describe file('/etc/sensu/conf.d/checks') do
  it { should be_directory }
  #  it { should be_owned_by 'sensu' }
end
describe file('/var/log/sensu') do
  it { should be_directory }
  it { should be_owned_by 'sensu' }
end

describe file('/var/log/sensu/sensu-api.log') do
  it { should be_file }
  it { should be_owned_by 'sensu' }
end

describe file('/var/log/sensu/sensu-client.log') do
  it { should be_file }
  it { should be_owned_by 'sensu' }
end

describe file('/var/log/sensu/sensu-server.log') do
  it { should be_file }
  it { should be_owned_by 'sensu' }
end

describe file('/etc/logrotate.d/sensu') do
  it { should be_file }
  it { should be_owned_by 'root' }
end

describe 'sensu client' do
  it 'is listening on port 3030' do
    expect(port(3030)).to be_listening
  end

  it 'has a running service of sensu-client' do
    expect(service('sensu-client')).to be_running
  end

  it 'has a enabled service of sensu-client' do
    expect(service('sensu-client')).to be_enabled
  end
end

describe 'sensu api' do
  it 'is listening on port 4567' do
    expect(port(4567)).to be_listening
  end

  it 'has a running service of sensu-api' do
    expect(service('sensu-api')).to be_running
  end

  it 'has a enabled service of sensu-api' do
    expect(service('sensu-api')).to be_enabled
  end
end

describe 'sensu server' do
  it 'has a running service of sensu-server' do
    expect(service('sensu-server')).to be_running
  end

  it 'has a enabled service of sensu-server' do
    expect(service('sensu-server')).to be_enabled
  end
end

describe 'uchiwa' do
  it 'is listening on port 3000' do
    expect(port(3000)).to be_listening
  end

  # it 'has a running service of uchiwa' do
  #   expect(service('uchiwa')).to be_running
  # end

  it 'has a enabled service of uchiwa' do
    expect(service('uchiwa')).to be_enabled
  end
end

describe command('curl -s http://localhost:3000/') do
  # test uchiwa login page
  its(:stdout) { should contain('uchiwa') }
end

describe command('curl -s -I "http://localhost:4567/health?consumers=1&messages=1"') do
  # test output
  its(:stdout) { should contain('HTTP/1.1 204') }
end

describe command('curl -s http://localhost:4567/info') do
  # test version
  its(:stdout) { should contain('1.0.2').after('version') }

  # test rabbitmq connect
  its(:stdout) { should contain('connected":true').after('transport') }

  # test redis connect
  its(:stdout) { should contain('connected":true').after('redis') }
end

#describe command('curl -s http://localhost:4567/checks') do
#  %w(check-banner.rb check-disk-usage.rb check-memory.rb check-load.rb check-fs-writable.rb).each do |check|
#    # test check
#    its(:stdout) { should contain(check).after('command') }
#  end
#
#  %w(metrics-disk-usage.rb metrics-redis-graphite.rb metrics-rabbitmq-overview.rb).each do |check|
#    # test metric
#    its(:stdout) { should contain(check).after('command') }
#  end
#end

describe command('curl -s http://localhost:4567/clients') do
  # test version
  its(:stdout) { should contain('1.0.2').after('version') }

  # test subscriptions
  its(:stdout) { should contain('linux').after('subscriptions') }

  # test subscriptions
  its(:stdout) { should contain('all').after('subscriptions') }
end

describe command('curl -s http://localhost:4567/events') do
  its(:stdout) { should eq('[]') }
end

describe command('curl -s http://localhost:4567/stashes') do
  its(:stdout) { should eq('[]') }
end
