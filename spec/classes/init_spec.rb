# frozen_string_literal: true

require 'spec_helper'

describe 'logstash_tcp_reporter' do
  on_supported_os.each do |os, os_facts|
    let(:facts) do
      os_facts.merge(
        is_pe: false,
      )
    end

    context "on #{os}" do
      context 'with default parameters' do
        it {
          expect(subject).to compile.with_all_deps
          expect(subject).to contain_class('logstash_tcp_reporter')
          expect(subject).to contain_class('logstash_tcp_reporter::params')

          expect(subject).to contain_file('/etc/puppetlabs/puppet/logstash_tcp.yaml').with(
            'ensure' => 'file',
            'content' => "---\n:host: 127.0.0.1\n:port: 5999\n:timeout: 10\n",
            'mode' => '0440',
            'owner' => 'puppet',
            'group' => 'puppet',
          )
        }
      end

      context 'with other server parameters' do
        let(:params) do
          {
            logstash_host: '8.8.8.8',
            logstash_port: 1337,
            logstash_timeout: 24,
            config_owner: 'somebody_else',
            config_group: 'somebody_else',
          }
        end

        it {
          expect(subject).to contain_class('logstash_tcp_reporter')
          expect(subject).to contain_class('logstash_tcp_reporter::params')

          expect(subject).to contain_file('/etc/puppetlabs/puppet/logstash_tcp.yaml').with(
            'ensure' => 'file',
            'content' => "---\n:host: 8.8.8.8\n:port: 1337\n:timeout: 24\n",
            'mode' => '0440',
            'owner' => 'somebody_else',
            'group' => 'somebody_else',
          )
        }
      end
    end
  end
end
