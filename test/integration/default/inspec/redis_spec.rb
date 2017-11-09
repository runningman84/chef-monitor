if os[:family] == 'redhat'
  redis_package = 'redis'
else
  redis_package = 'redis-server'
end

describe package(redis_package) do
  it { should be_installed }
end

describe 'redis server' do
  it 'is listening on port 6379' do
    expect(port(6379)).to be_listening
  end

  it 'has a running service of redis-server' do
    expect(service(redis_package)).to be_running
  end

  it 'has a enabled service of redis-server' do
    expect(service(redis_package)).to be_enabled
  end
end
