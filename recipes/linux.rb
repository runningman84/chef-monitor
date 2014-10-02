sensu_gem 'ohai'

sensu_check 'disk_usage' do
  #file '/system/check-disk.rb'
  command 'check-disk.rb -w 80 -c 90 -x nfs,tmpfs,fuse'
  handlers ['default']
  interval 30
  subscribers ['linux']
  additional({
    :occurrences => 2
  })
end

sensu_check 'memory' do
  #file '/system/check-mem.rb'
  command 'check-mem.rb -w 15 -c 10'
  handlers ['default']
  interval 30
  subscribers ['linux']
  additional({
    :occurrences => 2
  })
end

sensu_check 'swap' do
#file '/system/check-mem.rb'
  command 'check-mem.rb --swap -w 60 -c 50'
  handlers ['default']
  interval 30
  subscribers ['linux']
  additional({
    :occurrences => 2
  })
end

sensu_check 'load' do
  #file '/system/check-load.rb'
  command 'check-load.rb -w 10,15,25 -c 15,20,30'
  handlers ['default']
  interval 30
  subscribers ['linux']
  additional({
    :occurrences => 2
  })
end

sensu_check "fs_writeable_tmp" do
  command "check-fs-writable.rb -d /tmp"
  handlers ["default"]
  interval 30
  subscribers ['linux']
  additional({
    :occurrences => 2
  })
end

sensu_check "chef_client" do
  command "check-chef-client.rb"
  handlers ["default"]
  interval 30
  subscribers ['linux']
  additional({
    :occurrences => 2
  })
end