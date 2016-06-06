#!/usr/bin/env ruby
# see https://github.com/runningman84/sensu-plugins-sensu/blob/a5115abc767f52f46b34f519d1212beb4db32747/bin/handler-sensu-deregister.rb

require 'rubygems'
require 'sensu-handler'

class Deregister < Sensu::Handler
  def handle
    delete_sensu_client!
    delete_sensu_event!
  end

  def delete_sensu_client!
    response = api_request(:DELETE, '/clients/' + @event['client']['name']).code
    deletion_status(response)
  end

  def delete_sensu_event!
    api_request(:DELETE, '/events/' + @event['client']['name'] + '/api_call')
  end

  def deletion_status(code)
    case code
    when '202'
      puts "202: Successfully deleted Sensu client: #{@event['client']['name']}"
    when '404'
      puts "404: Unable to delete #{@event['client']['name']}, doesn't exist!"
    when '500'
      puts "500: Miscellaneous error when deleting #{@event['client']['name']}"
    else
      puts "#{res}: Completely unsure of what happened!"
    end
  end
end
