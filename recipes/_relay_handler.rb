
include_recipe 'monitor::_extensions'
include_recipe 'monitor::_graphite_search'

if node['sensu'].key?('graphite')

  unless node['sensu']['graphite']['host'].nil?

    cookbook_file File.join(node['monitor']['server_extension_dir'], 'relay.rb') do
      source 'extensions/relay.rb'
      mode 0755
      notifies :create, 'ruby_block[sensu_service_trigger]', :immediately
    end

    cookbook_file File.join(node['monitor']['server_extension_dir'], 'metrics.rb') do
      source 'extensions/metrics.rb'
      mode 0755
      notifies :create, 'ruby_block[sensu_service_trigger]', :immediately
    end

    json = {
      graphite: {
        host: node['sensu']['graphite']['host'],
        port: node['sensu']['graphite']['port']
      }
    }

    sensu_snippet 'relay' do
      content(
        json
      )
    end

  end

end
