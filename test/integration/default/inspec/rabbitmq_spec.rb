describe package('rabbitmq-server') do
  it { should be_installed }
end

describe 'rabbitmq server' do
  it 'is listening on port 5671' do
    expect(port(5671)).to be_listening
  end

  it 'has a running service of rabbitmq-server' do
    expect(service('rabbitmq-server')).to be_running
  end

  it 'has a enabled service of rabbitmq-server' do
    expect(service('rabbitmq-server')).to be_enabled
  end
end

describe command('rabbitmqctl list_connections') do
  # test uchiwa login page
  its(:stdout) { should include('running')} # TODO: after sensu { should contain('running').after('sensu') }
end

describe command('rabbitmqctl list_users') do
  # test uchiwa login page
  its(:stdout) { should include('sensu') }
end
