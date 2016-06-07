#!/usr/bin/env ruby
#

require 'rubygems'
require 'sensu-handler'

class Maintenance < Sensu::Handler
  def handle
    if @event['check']['expire'].to_i > 0
      maintenance_on!
    else
      maintenance_off!
    end
  end

  def maintenance_on!
    content = {
      'path' => "maintenance/#{@event['client']['name']}",
      'content' => {
        'reason' => "Maintenance requested by #{@event['check']['user']}",
        'source' => 'cli'
      },
      'expire' => @event['check']['expire'].to_i
    }
    response = stash_request(:POST, "/stashes", content.to_json.to_s).code
    stash_add_status(response)
    api_request(:DELETE, '/events/' + @event['client']['name'] + '/api_call')
  end

  def maintenance_off!
    response = stash_request(:DELETE, "/stashes/maintenance/#{@event['client']['name']}").code
    stash_delete_status(response)
    api_request(:DELETE, '/events/' + @event['client']['name'] + '/api_call')
  end

  def api_settings
     @api_settings ||= if ENV['SENSU_API_URL']
       uri = URI(ENV['SENSU_API_URL'])
       {
         'host' => uri.host,
         'port' => uri.port,
         'user' => uri.user,
         'password' => uri.password
       }
     else
       settings['api']
     end
   end

   def stash_request(method, path, data = '', &blk)
     if api_settings.nil?
       raise "api.json settings not found."
     end
     domain = api_settings['host'].start_with?('http') ? api_settings['host'] : 'http://' + api_settings['host']
     uri = URI("#{domain}:#{api_settings['port']}#{path}")
     req = net_http_req_class(method).new(uri, initheader = {'Content-Type' =>'application/json'})
     req.body = data
     if api_settings['user'] && api_settings['password']
       req.basic_auth(api_settings['user'], api_settings['password'])
     end
     yield(req) if block_given?
     res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
       http.request(req)
     end
     res
   end

   def stash_add_status(code)
      case code
      when '201'
        puts "201: Successfully added maintenance stash for Sensu client: #{@event['client']['name']}"
      when '500'
        puts "500: Miscellaneous error when adding stash for Sensu client: #{@event['client']['name']}"
      else
        puts "#{code}: Completely unsure of what happened!"
      end
    end

  def stash_delete_status(code)
     case code
     when '204'
       puts "204: Successfully deleted maintenance stash for Sensu client: #{@event['client']['name']}"
     when '404'
       puts "404: Maintenance stash for Sensu client: #{@event['client']['name']} was not found"
     when '500'
       puts "500: Miscellaneous error when deleted stash for Sensu client: #{@event['client']['name']}"
     else
       puts "#{code}: Completely unsure of what happened!"
     end
   end


  end
