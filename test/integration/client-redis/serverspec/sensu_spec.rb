require 'serverspec'

# Required by serverspec
set :backend, :exec

describe package('sensu') do
  it { should be_installed }
end

describe user('sensu') do
  it { should exist }
end

describe file('/etc/sensu') do
  it { should be_directory }
  it { should be_owned_by 'root' }
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


describe file('/var/log/sensu/sensu-client.log') do
  it { should be_file }
  it { should be_owned_by 'sensu' }
end

describe file('/etc/logrotate.d/sensu') do
  it { should be_file }
  it { should be_owned_by 'root' }
end

describe 'sensu client' do
  it 'has a running service of sensu-client' do
    expect(service('sensu-client')).to be_running
  end

  it 'has a enabled service of sensu-client' do
    expect(service('sensu-client')).to be_enabled
  end
end
