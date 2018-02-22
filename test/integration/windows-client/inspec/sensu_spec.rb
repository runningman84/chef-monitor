describe package('sensu') do
  it { should be_installed }
end

describe user('sensu') do
  it { should exist }
end

describe file('/etc/sensu') do
  it { should be_directory }

end



describe json('/etc/sensu/config.json') do
    its(['transport','name']) { should eq 'rabbitmq'}
    its(['rabbitmq',0,'host']) { should eq 'localhost'} # TODO: port should be 5671
    its(['redis','host']) { should eq 'localhost'} # TODO: port should be 6379
    its(['api','host']) { should eq 'localhost'} # TODO: port should be 4567
end

describe file('/etc/sensu/conf.d') do
  it { should be_directory }
end

describe file('/etc/sensu/conf.d/checks') do
  it { should be_directory }
end
describe file('/var/log/sensu') do
  it { should be_directory }
end


describe file('/var/log/sensu/sensu-client.log') do
  it { should be_file }
end

describe 'sensu client' do
  it 'has a running service of sensu-client' do
    expect(service('sensu-client')).to be_running
  end

  it 'has a enabled service of sensu-client' do
    expect(service('sensu-client')).to be_enabled
  end
end
