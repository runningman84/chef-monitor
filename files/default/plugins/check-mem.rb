#!/usr/bin/env ruby
#
# Check Linux memory
# ===
#
# Copyright 2012 Kwarter, Inc <platforms@kwarter.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'ohai'

class CheckMemory < Sensu::Plugin::Check::CLI

  # Fire warning/critical if free + buffer + cache goes below a certain threshold

  option :warn,
         :short       => '-w W',
         :long        => '--warn W',
         :description => 'Memory WARNING threshold in %',
         :proc        => proc { |a| a.to_i },
         :required    => true
  option :crit,
         :short       => '-c W',
         :long        => '--crit W',
         :description => 'Memory CRITICAL threshold in %',
         :proc        => proc { |a| a.to_i },
         :required    => true
  option :swap,
         :short       => '-s',
         :long        => '--swap',
         :description => 'Memory CRITICAL threshold in %',
         :boolean     => true,
         :default     => false

  def run
    system = Ohai::System.new()
    system.require_plugin('os')
    system.require_plugin("#{system[:os]}/memory")

    if config[:swap]
      total    = system[:memory][:swap][:total].to_i
      free     = system[:memory][:swap][:free].to_i
      buffered = 0
      cached   = system[:memory][:swap][:cached].to_i

      # some boxes do not have swap
      if total == 0
        ok
        return
      end

    else
      total    = system[:memory][:total].to_i
      free     = system[:memory][:free].to_i
      buffered = system[:memory][:buffers].to_i
      cached   = system[:memory][:cached].to_i
    end

    percent = ((free + buffered + cached) * 100) / total
    if percent < config[:warn]
      warning
    elsif percent < config[:crit]
      critical
    else
      ok
    end
  end

end
