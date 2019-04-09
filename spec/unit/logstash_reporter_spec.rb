#! /usr/bin/env ruby
# frozen_string_literal: true

require 'spec_helper'
require 'puppet/reports'
require 'time'
require 'pathname'
require 'tempfile'
require 'fileutils'

processor = Puppet::Reports.report(:logstash_tcp)

describe processor do
  describe '#process' do
    server = Object
    report = Object

    after :each do
      server.close
    end

    before :each do
      server = TCPServer.new 5999
      report = YAML.load_file(File.join(fixtures_directory, 'report.yaml')).extend processor
    end

    it 'sends the right data to the remote server' do
      report.process

      data = JSON.parse(server.accept.read)

      expect(data).not_to be_empty
      expect(data['@version']).to eq(1)
      expect(data['@timestamp']).to eq(Time.now.utc.iso8601)
      expect(data['host']).to eq('host.example.com')
      expect(data['puppet_configuration_version']).to eq(1_554_565_875)
      expect(data['puppet_environment']).to eq('testing')
      expect(data['puppet_noop']).to eq('false')
      expect(data['puppet_report_format']).to eq(10)
      expect(data['puppet_status']).to eq('unchanged')
      expect(data['puppet_tags']).to eq(['info', 'notice'])
      expect(data['puppet_time_end']).to eq('2019-04-06T16:06:23Z')
      expect(data['puppet_time_start']).to eq('2019-04-06T16:06:12Z')
      expect(data['puppet_version']).to eq('6.2.0')
    end
  end
end
