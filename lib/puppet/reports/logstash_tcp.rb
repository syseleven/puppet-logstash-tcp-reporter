# frozen_string_literal: true

require 'puppet'
require 'puppet/util'
require 'yaml'
require 'json'
require 'fileutils'
require 'date'
require 'time'
require 'openssl'
require 'socket'

unless Puppet.version >= '5.0.0'
  raise 'This report processor requires Puppet version 5.0.0 or later'
end

Puppet::Reports.register_report(:logstash_tcp) do
  desc <<-DESCRIPTION
  Reports metrics and logs of Puppet Runs to logstash tcp server with SSL/TLS support
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

    logstash_host = YAML.load_file(CONFIGURATION_FILE)[:host]
    logstash_port = YAML.load_file(CONFIGURATION_FILE)[:port]
    logstash_timeout = YAML.load_file(CONFIGURATION_FILE)[:timeout]

    ssl_enable = YAML.load_file(CONFIGURATION_FILE)[:ssl_enable]
    ssl_cert = YAML.load_file(CONFIGURATION_FILE)[:ssl_cert]
    ssl_key = YAML.load_file(CONFIGURATION_FILE)[:ssl_key]
    ssl_version = YAML.load_file(CONFIGURATION_FILE)[:ssl_version]
    ssl_ca_path = YAML.load_file(CONFIGURATION_FILE)[:ssl_ca_path]
    ssl_ca_file = YAML.load_file(CONFIGURATION_FILE)[:ssl_ca_file]

    begin
      Timeout.timeout(logstash_timeout) do
        logstash_socket = TCPSocket.new(logstash_host.to_s, logstash_port)

        if ssl_enable
          context = OpenSSL::SSL::SSLContext.new
          context.verify_mode = OpenSSL::SSL::VERIFY_PEER
          context.cert = OpenSSL::X509::Certificate.new(File.open(ssl_cert)) if ssl_cert != 'None'
          context.key = OpenSSL::PKey::RSA.new(File.open(ssl_key)) if ssl_key != 'None'
          context.ssl_version = ssl_version
          context.ca_path = ssl_ca_path if ssl_ca_path != 'None'
          context.ca_file = ssl_ca_file if ssl_ca_file != 'None'

          logstash_socket_ssl = OpenSSL::SSL::SSLSocket.new(logstash_socket, context)

          logstash_socket_ssl.connect
          logstash_socket_ssl.puts(report.to_json)
          logstash_socket_ssl.close
        else
          logstash_socket.puts(report.to_json)
        end

        logstash_socket.close
      end
    rescue Exception => e
      Puppet.err("Failed to write to #{logstash_host} on port #{logstash_port} via tcp: #{e.message}")
    end
  end
end
