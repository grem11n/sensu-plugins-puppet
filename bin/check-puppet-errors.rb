#! /usr/bin/env ruby
#
# check-puppet-errors
#
# DESCRIPTION:
#   Check if Puppet ran with errors
#
# OUTPUT:
#   plain-text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   Critical if last run had errors
#
#   check-puppet-errors --summary-file /opt/puppetlabs/puppet/cache/state/last_run_summary.yaml
#
# NOTES:
#
# LICENSE:
#   Copyright 2014 Sonian, Inc. and contributors. <support@sensuapp.org>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'yaml'
require 'json'
require 'time'

class PuppetLastRun < Sensu::Plugin::Check::CLI
  option :summary_file,
         short:       '-s PATH',
         long:        '--summary-file PATH',
         default:     '/opt/puppetlabs/puppet/cache/state/last_run_summary.yaml',
         description: 'Location of last_run_summary.yaml file'

  def run
    unless File.exist?(config[:summary_file])
      unknown "File #{config[:summary_file]} not found"
    end

    begin
      summary = YAML.load_file(config[:summary_file])
      if summary['events']
        @failures = summary['events']['failure'].to_i
      else
        critical "#{config[:summary_file]} is missing information about the events"
      end
    rescue
      unknown "Could not process #{config[:summary_file]}"
    end

    @message = 'Puppet run'

    if @failures > 0
      @message += " had #{failures} failures"
      critical @message
    else
      @message += ' was successful'
      ok @message
    end
  end
end
