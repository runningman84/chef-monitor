require 'serverspec'

# Required by serverspec
set :backend, :exec

describe package('rabbitmq-server') do
  it { should_not be_installed }
end
