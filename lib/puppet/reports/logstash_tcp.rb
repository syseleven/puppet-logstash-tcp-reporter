# frozen_string_literal: true

require 'puppet'
require 'puppet/util'
require 'yaml'
require 'fileutils'
require 'date'
require 'time'

unless Puppet.version >= '5.0.0'
  raise 'This report processor requires Puppet version 5.0.0 or later'
end

Puppet::Reports.register_report(:logstash_tcp) do
  desc <<-DESCRIPTION
  Reports metrics and logs of Puppet Runs to logstash tcp server
  DESCRIPTION

  CONFIGURATION_FILE = File.join([File.dirname(Puppet.settings[:config]), 'logstash_tcp.yaml'])

  unless File.exist?(CONFIGURATION_FILE)
    raise(Puppet::ParseError, "Logstash tcp configuration file #{CONFIGURATION_FILE} missing or not readable!")
  end

  def process
    report = {}

    report = {
      'host' => host,
      '@timestamp' => Time.now.utc.iso8601,
      '@version' => 1,
      'puppet_configuration_version' => configuration_version,
      'puppet_environment' => environment,
      'puppet_noop' => noop ? 'true' : 'false',
      'puppet_version' => puppet_version,
      'puppet_report_format' => report_format,
      'puppet_status' => status,
      'puppet_time_start' => logs.first.time.utc.iso8601,
      'puppet_time_end' => logs.last.time.utc.iso8601,
    }

    messages = []
    tags = []

    logs.each do |log|
      time = log.time.utc.iso8601
      level = log.level
      message = log.message

      messages << "(#{time})\t(#{level}) #{message}"
      tags << log.tags.join(',')
    end

    report['puppet_logs'] = messages.join("\n")
    report['puppet_tags'] = tags.flatten.join(',').split(',').sort.uniq

    report['metrics'] = {}

    metrics.each do |key, value|
      report['metrics'][key] = {}

      value.values.each do |item|
        report['metrics'][key][item[1].tr('[A-Z ]', '[a-z_]')] = item[2]
      end
    end

    host = YAML.load_file(CONFIGURATION_FILE)[:host]
    port = YAML.load_file(CONFIGURATION_FILE)[:port]
    timeout = YAML.load_file(CONFIGURATION_FILE)[:timeout]

    begin
      Timeout.timeout(timeout) do
        logstash = TCPSocket.new host.to_s, port

        logstash.puts(report.to_json)
        logstash.close
      end
    rescue Exception => e
      Puppet.err("Failed to write to #{host} on port #{port} via tcp: #{e.message}")
    end
  end
end
